# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-01-09

## [1.1.0](https://github.com/agronod/.github/compare/v1.0.0...v1.1.0) (2026-01-09)


### Features

* add automated release pipeline with changelog ([#25](https://github.com/agronod/.github/issues/25)) ([7b526d2](https://github.com/agronod/.github/commit/7b526d24dc0379a7435d1f36da44622fcb5fd164))




## [1.0.0] - 2026-01-09

### Added

- Reusable workflows for Node.js CI/CD with container builds
- Reusable workflows for Python CI/CD with container builds
- Reusable workflows for .NET CI/CD with container builds
- Reusable workflows for Go CI/CD with container builds
- Shared workflows for .NET NuGet package publishing
- Shared workflows for Node.js npm package publishing
- Semantic version calculator (`next-version.yaml`)
- GitHub release creator (`create-release.yml`)
- Changelog updater (`update-changelog.yml`)
- Container image builder and pusher (`build-and-push-image.yml`)
- Trivy vulnerability scanner (`scan-and-check-image.yml`)
- GitOps application promoter (`promote-application.yml`)
- Pull request validation workflows for all languages
- Claude AI assistant integration for PR reviews
- AI steering documentation in `.agents/steering/`
- Pull request template

### Contributors

- @fabian-heib
- @robingedda
- @davidbilling
