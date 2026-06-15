# Agency Base Template

A neutral Expo and React Native starter for initializing new application projects.

## Included

* Expo Router
* TypeScript strict mode
* Android, iOS, and web support
* Light and dark theme support
* Reusable UI primitives
* ESLint
* Jest with a baseline smoke test
* Generic PowerShell validation
* Generic AI project-context packing

## Create a New Project

Run this command from the parent directory where the new project should be created:

```powershell
npx create-expo-app@latest MyNewApp `
  --template https://github.com/schommy98-learn/agency-base-template `
  --no-agents-md
```

Replace `MyNewApp` with the new project folder name.

The `--no-agents-md` option prevents Expo from adding generated AI-agent configuration files. Add project-specific AI workflow files intentionally after the project is created.

## Validate a Generated Project

From the generated project directory:

```powershell
npm run validate
```

The validation pipeline runs:

* Node version
* Expo dependency alignment
* Expo Doctor
* TypeScript
* ESLint
* Jest

It does not start Expo, create native folders, build an application, launch an emulator, or deploy anything.

## Start Development

```powershell
npx expo start --clear
```

The Expo development server is intentionally excluded from automated validation because it is a persistent process.

## Pack Project Context

Generate an AI-readable project snapshot:

```powershell
.\pack-context.ps1
```

To explicitly control the project name:

```powershell
.\pack-context.ps1 -ProjectName "MyNewApp"
```

The generated context file excludes dependencies, caches, binaries, databases, native build folders, secrets, and lock files.

Always inspect the generated context file for secrets before uploading it to an AI service.

## New Project Setup Checklist

After creating a project:

1. Confirm the application name and slug in `app.json`.
2. Add an application-specific URL scheme only when required.
3. Add product scope and architecture documentation.
4. Add project-specific `.clinerules` and `.clineignore`.
5. Add the project-specific CLINE workflow documents.
6. Run `npm run validate`.
7. Launch at least one target platform manually.
8. Commit the validated clean scaffold before feature development.

## Template Maintenance

Before publishing an AgencyBaseTemplate update:

1. Make one bounded template change at a time.
2. Run `npm run validate`.
3. Confirm no application-specific files or dependencies remain.
4. Commit and push the template repository.
5. Generate a disposable project from the GitHub template.
6. Run `npm run validate` in the disposable project.
7. Confirm the disposable project launches successfully.
8. Delete the disposable project after validation.

Do not use `--force`, `--legacy-peer-deps`, or automated breaking dependency repairs to make a generated project install.