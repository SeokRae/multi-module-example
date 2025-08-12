package com.example.batch.listener;

import lombok.extern.slf4j.Slf4j;
import org.springframework.batch.core.JobExecution;
import org.springframework.batch.core.JobExecutionListener;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.LocalDateTime;

@Slf4j
@Component
public class BatchJobListener implements JobExecutionListener {

    @Override
    public void beforeJob(JobExecution jobExecution) {
        log.info("🚀 Starting batch job: {} at {}", 
                jobExecution.getJobInstance().getJobName(),
                LocalDateTime.now());
                
        log.info("Job Parameters: {}", jobExecution.getJobParameters().getParameters());
    }

    @Override
    public void afterJob(JobExecution jobExecution) {
        String jobName = jobExecution.getJobInstance().getJobName();
        String status = jobExecution.getStatus().toString();
        
        Duration duration = Duration.between(
                jobExecution.getStartTime(),
                jobExecution.getEndTime()
        );
        
        if (jobExecution.getStatus().isUnsuccessful()) {
            log.error("❌ Batch job failed: {} - Status: {} - Duration: {} seconds", 
                    jobName, status, duration.getSeconds());
                    
            // 실패한 경우 상세 정보 로깅
            jobExecution.getAllFailureExceptions().forEach(throwable -> 
                log.error("Failure exception: ", throwable)
            );
            
            // TODO: 이메일 알림 발송
            sendFailureNotification(jobName, jobExecution);
            
        } else {
            log.info("✅ Batch job completed: {} - Status: {} - Duration: {} seconds - Read: {} / Write: {} / Skip: {}", 
                    jobName, 
                    status, 
                    duration.getSeconds(),
                    jobExecution.getStepExecutions().stream()
                            .mapToLong(stepExecution -> stepExecution.getReadCount()).sum(),
                    jobExecution.getStepExecutions().stream()
                            .mapToLong(stepExecution -> stepExecution.getWriteCount()).sum(),
                    jobExecution.getStepExecutions().stream()
                            .mapToLong(stepExecution -> stepExecution.getSkipCount()).sum()
            );
        }
    }

    private void sendFailureNotification(String jobName, JobExecution jobExecution) {
        // TODO: 실제 이메일 발송 로직 구현
        log.warn("📧 Failure notification should be sent for job: {}", jobName);
        
        // 예시: Spring Mail 또는 외부 알림 서비스와 연동
        // mailService.sendBatchFailureAlert(jobName, jobExecution.getAllFailureExceptions());
    }
}