package com.example.batch.config;

import org.quartz.JobBuilder;
import org.quartz.JobDetail;
import org.quartz.SimpleScheduleBuilder;
import org.quartz.Trigger;
import org.quartz.TriggerBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.quartz.SchedulerFactoryBean;

import javax.sql.DataSource;

@Configuration
@EnableScheduling
public class QuartzConfiguration {

    @Bean
    public SchedulerFactoryBean schedulerFactoryBean(DataSource dataSource) {
        SchedulerFactoryBean factory = new SchedulerFactoryBean();
        factory.setDataSource(dataSource);
        factory.setApplicationContextSchedulerContextKey("applicationContext");
        factory.setWaitForJobsToCompleteOnShutdown(true);
        factory.setAutoStartup(true);
        return factory;
    }

    @Bean
    public JobDetail userStatisticsJobDetail() {
        return JobBuilder.newJob()
                .ofType(com.example.batch.scheduler.UserStatisticsQuartzJob.class)
                .withIdentity("userStatisticsJob")
                .withDescription("Daily user statistics generation job")
                .storeDurably()
                .build();
    }

    @Bean
    public Trigger userStatisticsJobTrigger() {
        return TriggerBuilder.newTrigger()
                .forJob(userStatisticsJobDetail())
                .withIdentity("userStatisticsJobTrigger")
                .withDescription("Trigger for user statistics job")
                .withSchedule(SimpleScheduleBuilder.simpleSchedule()
                        .withIntervalInHours(24)
                        .repeatForever())
                .build();
    }

    @Bean
    public JobDetail orderReportJobDetail() {
        return JobBuilder.newJob()
                .ofType(com.example.batch.scheduler.OrderReportQuartzJob.class)
                .withIdentity("orderReportJob")
                .withDescription("Daily order report generation job")
                .storeDurably()
                .build();
    }

    @Bean
    public Trigger orderReportJobTrigger() {
        return TriggerBuilder.newTrigger()
                .forJob(orderReportJobDetail())
                .withIdentity("orderReportJobTrigger")
                .withDescription("Trigger for order report job")
                .withSchedule(SimpleScheduleBuilder.simpleSchedule()
                        .withIntervalInHours(24)
                        .repeatForever())
                .build();
    }
}