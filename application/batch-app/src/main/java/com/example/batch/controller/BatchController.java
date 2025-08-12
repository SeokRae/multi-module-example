package com.example.batch.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.JobExecution;
import org.springframework.batch.core.JobParameters;
import org.springframework.batch.core.JobParametersBuilder;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.batch.core.explore.JobExplorer;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping("/api/v1/batch")
@RequiredArgsConstructor
public class BatchController {

    private final JobLauncher jobLauncher;
    private final JobExplorer jobExplorer;
    private final Job userStatisticsJob;
    private final Job orderReportJob;

    @PostMapping("/jobs/user-statistics")
    public ResponseEntity<?> runUserStatisticsJob() {
        try {
            JobParameters jobParameters = new JobParametersBuilder()
                    .addLong("timestamp", System.currentTimeMillis())
                    .toJobParameters();
                    
            JobExecution jobExecution = jobLauncher.run(userStatisticsJob, jobParameters);
            
            return ResponseEntity.ok(Map.of(
                "jobId", jobExecution.getId(),
                "jobName", "userStatisticsJob",
                "status", jobExecution.getStatus().name(),
                "startTime", jobExecution.getStartTime(),
                "message", "User statistics job started successfully"
            ));
        } catch (Exception e) {
            log.error("Failed to start user statistics job", e);
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/jobs/order-report")
    public ResponseEntity<?> runOrderReportJob() {
        try {
            JobParameters jobParameters = new JobParametersBuilder()
                    .addLong("timestamp", System.currentTimeMillis())
                    .toJobParameters();
                    
            JobExecution jobExecution = jobLauncher.run(orderReportJob, jobParameters);
            
            return ResponseEntity.ok(Map.of(
                "jobId", jobExecution.getId(),
                "jobName", "orderReportJob",
                "status", jobExecution.getStatus().name(),
                "startTime", jobExecution.getStartTime(),
                "message", "Order report job started successfully"
            ));
        } catch (Exception e) {
            log.error("Failed to start order report job", e);
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/jobs/{jobName}/status")
    public ResponseEntity<?> getJobStatus(@PathVariable String jobName) {
        try {
            var jobInstances = jobExplorer.getJobInstances(jobName, 0, 10);
            
            if (jobInstances.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            var recentExecutions = jobInstances.stream()
                    .flatMap(instance -> jobExplorer.getJobExecutions(instance).stream())
                    .limit(5)
                    .map(execution -> Map.of(
                        "executionId", execution.getId(),
                        "status", execution.getStatus().name(),
                        "startTime", execution.getStartTime(),
                        "endTime", execution.getEndTime(),
                        "duration", execution.getEndTime() != null ? 
                            java.time.Duration.between(execution.getStartTime(), 
                                                     execution.getEndTime()).getSeconds() + "s" : "Running"
                    ))
                    .collect(Collectors.toList());
            
            return ResponseEntity.ok(Map.of(
                "jobName", jobName,
                "recentExecutions", recentExecutions
            ));
        } catch (Exception e) {
            log.error("Failed to get job status for: {}", jobName, e);
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/jobs")
    public ResponseEntity<?> getAllJobNames() {
        try {
            var jobNames = jobExplorer.getJobNames();
            return ResponseEntity.ok(Map.of(
                "totalJobs", jobNames.size(),
                "jobNames", jobNames
            ));
        } catch (Exception e) {
            log.error("Failed to get job names", e);
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", e.getMessage()));
        }
    }
}