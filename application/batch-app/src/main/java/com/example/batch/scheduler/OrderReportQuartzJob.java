package com.example.batch.scheduler;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.springframework.batch.core.JobParameters;
import org.springframework.batch.core.JobParametersBuilder;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class OrderReportQuartzJob implements Job {

    private final JobLauncher jobLauncher;
    private final org.springframework.batch.core.Job orderReportJob;

    @Override
    public void execute(JobExecutionContext context) throws JobExecutionException {
        try {
            log.info("Starting Order Report Quartz Job");
            
            JobParameters jobParameters = new JobParametersBuilder()
                    .addLong("timestamp", System.currentTimeMillis())
                    .toJobParameters();
                    
            jobLauncher.run(orderReportJob, jobParameters);
            
            log.info("Order Report Quartz Job completed successfully");
        } catch (Exception e) {
            log.error("Failed to execute Order Report Quartz Job", e);
            throw new JobExecutionException(e);
        }
    }
}