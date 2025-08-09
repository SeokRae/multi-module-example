# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Status
This is currently an empty project template set up for a multi-module Java example. The project structure indicates it's intended to be a Maven-based multi-module project.

## Current Structure
- IntelliJ IDEA project with basic configuration
- Git repository initialized
- No source code, build files, or documentation yet implemented

## Expected Development Setup
Based on the project name and IntelliJ configuration, this will likely become a Maven multi-module project. When developed, typical commands would include:

- Build: `mvn clean compile`
- Test: `mvn test`
- Package: `mvn clean package`
- Install: `mvn clean install`

## Architecture Notes
This appears to be set up as a learning/example project for demonstrating multi-module Maven project structure. Once developed, it would typically contain:

- Parent POM defining module structure and dependencies
- Multiple child modules with their own POMs
- Shared dependencies and build configuration at parent level

## Development Notes
- Project is currently in template/empty state
- When adding modules, follow Maven multi-module conventions
- IntelliJ IDEA project files are configured for Java development