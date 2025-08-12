package com.example.batch.job;

import com.example.batch.model.OrderReport;
import com.example.order.domain.Order;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.JobParameters;
import org.springframework.batch.core.JobParametersInvalidException;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.batch.core.repository.JobExecutionAlreadyRunningException;
import org.springframework.batch.core.repository.JobInstanceAlreadyCompleteException;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.repository.JobRestartException;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.item.ItemProcessor;
import org.springframework.batch.item.ItemReader;
import org.springframework.batch.item.ItemWriter;
import org.springframework.batch.item.database.JdbcCursorItemReader;
import org.springframework.batch.item.database.JdbcBatchItemWriter;
import org.springframework.batch.item.database.builder.JdbcCursorItemReaderBuilder;
import org.springframework.batch.item.database.builder.JdbcBatchItemWriterBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;

import javax.sql.DataSource;
import java.time.LocalDateTime;

@Slf4j
@Configuration
@RequiredArgsConstructor
public class OrderReportJobConfiguration {

    private final JobRepository jobRepository;
    private final PlatformTransactionManager transactionManager;
    private final DataSource dataSource;

    private static final int CHUNK_SIZE = 50;

    @Bean
    public Job orderReportJob() {
        return new JobBuilder("orderReportJob", jobRepository)
                .start(orderReportStep())
                .build();
    }

    @Bean
    public Step orderReportStep() {
        return new StepBuilder("orderReportStep", jobRepository)
                .<Order, OrderReport>chunk(CHUNK_SIZE, transactionManager)
                .reader(orderReader())
                .processor(orderReportProcessor())
                .writer(orderReportWriter())
                .build();
    }

    @Bean
    public ItemReader<Order> orderReader() {
        return new JdbcCursorItemReaderBuilder<Order>()
                .name("orderReader")
                .dataSource(dataSource)
                .sql("""
                    SELECT o.id, o.user_id, o.status, o.total_amount, o.order_date, o.created_at, o.updated_at,
                           u.email as user_email,
                           COUNT(oi.id) as total_items
                    FROM orders o
                    LEFT JOIN users u ON o.user_id = u.id
                    LEFT JOIN order_items oi ON o.id = oi.order_id
                    WHERE o.order_date >= DATEADD('DAY', -1, CURRENT_DATE)
                    GROUP BY o.id, o.user_id, o.status, o.total_amount, o.order_date, o.created_at, o.updated_at, u.email
                    ORDER BY o.order_date DESC
                    """)
                .rowMapper(new BeanPropertyRowMapper<>(Order.class))
                .build();
    }

    @Bean
    public ItemProcessor<Order, OrderReport> orderReportProcessor() {
        return order -> {
            log.debug("Processing order report for order: {}", order.getId());
            
            return OrderReport.builder()
                    .orderId(order.getId())
                    .userId(order.getUserId())
                    .userEmail("") // UserService에서 조회 필요
                    .orderStatus(order.getStatus().name())
                    .totalAmount(order.getTotalAmount())
                    .totalItems(order.getOrderItems() != null ? order.getOrderItems().size() : 0)
                    .orderDate(order.getOrderDate())
                    .reportDate(LocalDateTime.now())
                    .reportPeriod("DAILY")
                    .build();
        };
    }

    @Bean
    public ItemWriter<OrderReport> orderReportWriter() {
        return new JdbcBatchItemWriterBuilder<OrderReport>()
                .dataSource(dataSource)
                .sql("""
                    INSERT INTO order_reports 
                    (order_id, user_id, user_email, order_status, total_amount, total_items, order_date, report_date, report_period)
                    VALUES (:orderId, :userId, :userEmail, :orderStatus, :totalAmount, :totalItems, :orderDate, :reportDate, :reportPeriod)
                    ON DUPLICATE KEY UPDATE
                    order_status = VALUES(order_status),
                    total_amount = VALUES(total_amount),
                    total_items = VALUES(total_items),
                    report_date = VALUES(report_date)
                    """)
                .beanMapped()
                .build();
    }

    @Component
    @RequiredArgsConstructor
    public static class OrderReportJobScheduler {
        
        private final JobLauncher jobLauncher;
        private final Job orderReportJob;

        @Scheduled(cron = "0 30 1 * * ?") // 매일 오전 1:30 실행
        public void runOrderReportJob() {
            try {
                log.info("Starting Order Report Job");
                jobLauncher.run(orderReportJob, new JobParameters());
                log.info("Order Report Job completed successfully");
            } catch (JobExecutionAlreadyRunningException | JobRestartException |
                     JobInstanceAlreadyCompleteException | JobParametersInvalidException e) {
                log.error("Failed to run Order Report Job", e);
            }
        }
    }
}