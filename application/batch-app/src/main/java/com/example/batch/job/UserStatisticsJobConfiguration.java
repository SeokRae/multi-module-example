package com.example.batch.job;

import com.example.batch.model.UserStatistics;
import com.example.user.domain.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.JobParameters;
import org.springframework.batch.core.JobParametersInvalidException;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.job.builder.JobBuilder;
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
import org.springframework.batch.core.launch.JobLauncher;
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
public class UserStatisticsJobConfiguration {

    private final JobRepository jobRepository;
    private final PlatformTransactionManager transactionManager;
    private final DataSource dataSource;

    private static final int CHUNK_SIZE = 100;

    @Bean
    public Job userStatisticsJob() {
        return new JobBuilder("userStatisticsJob", jobRepository)
                .start(userStatisticsStep())
                .build();
    }

    @Bean
    public Step userStatisticsStep() {
        return new StepBuilder("userStatisticsStep", jobRepository)
                .<User, UserStatistics>chunk(CHUNK_SIZE, transactionManager)
                .reader(userReader())
                .processor(userStatisticsProcessor())
                .writer(userStatisticsWriter())
                .build();
    }

    @Bean
    public ItemReader<User> userReader() {
        return new JdbcCursorItemReaderBuilder<User>()
                .name("userReader")
                .dataSource(dataSource)
                .sql("SELECT id, name, email, role, created_at, updated_at, is_active FROM users WHERE is_active = true")
                .rowMapper(new BeanPropertyRowMapper<>(User.class))
                .build();
    }

    @Bean
    public ItemProcessor<User, UserStatistics> userStatisticsProcessor() {
        return user -> {
            log.debug("Processing user statistics for user: {}", user.getEmail());
            
            return UserStatistics.builder()
                    .userId(user.getId())
                    .userName(user.getName())
                    .userEmail(user.getEmail())
                    .userRole(user.getRole().name())
                    .registrationDate(user.getCreatedAt())
                    .lastActiveDate(user.getUpdatedAt())
                    .isActive(user.isActive())
                    .statisticsDate(LocalDateTime.now())
                    .build();
        };
    }

    @Bean
    public ItemWriter<UserStatistics> userStatisticsWriter() {
        return new JdbcBatchItemWriterBuilder<UserStatistics>()
                .dataSource(dataSource)
                .sql("""
                    INSERT INTO user_statistics 
                    (user_id, user_name, user_email, user_role, registration_date, last_active_date, is_active, statistics_date)
                    VALUES (:userId, :userName, :userEmail, :userRole, :registrationDate, :lastActiveDate, :isActive, :statisticsDate)
                    ON DUPLICATE KEY UPDATE
                    user_name = VALUES(user_name),
                    user_email = VALUES(user_email),
                    user_role = VALUES(user_role),
                    last_active_date = VALUES(last_active_date),
                    is_active = VALUES(is_active),
                    statistics_date = VALUES(statistics_date)
                    """)
                .beanMapped()
                .build();
    }

    @Component
    @RequiredArgsConstructor
    public static class UserStatisticsJobScheduler {
        
        private final JobLauncher jobLauncher;
        private final Job userStatisticsJob;

        @Scheduled(cron = "0 0 2 * * ?") // 매일 오전 2시 실행
        public void runUserStatisticsJob() {
            try {
                log.info("Starting User Statistics Job");
                jobLauncher.run(userStatisticsJob, new JobParameters());
                log.info("User Statistics Job completed successfully");
            } catch (JobExecutionAlreadyRunningException | JobRestartException |
                     JobInstanceAlreadyCompleteException | JobParametersInvalidException e) {
                log.error("Failed to run User Statistics Job", e);
            }
        }
    }
}