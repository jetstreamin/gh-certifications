# GitHub Certifications Learning Repository

A comprehensive learning hub for GitHub security and advanced topics certifications, with step-by-step guides, quick references, and verified best practices.

## 📖 Documentation

**Exam Certifications:**
- **[GH-600: Developing in Agentic AI Systems](docs/gh-600-exam-guide.md)** — Complete study guide for the Microsoft Certified: GitHub Agentic AI Developer exam. Covers all 6 skill areas with practical patterns and implementation examples.

**Agent Administration, SDK & Memory:**
- **[Custom Agents Administration Guide](docs/custom-agents-admin-guide.md)** — Setup and governance for organization-level custom Copilot agents. Repository structure, compliance, security, and lifecycle management.
- **[Copilot SDK: Custom Agents Implementation](docs/copilot-sdk-custom-agents.md)** — Developer guide for building custom agents with the Copilot SDK. Configuration, event handling, tool scoping, and production patterns.
- **[Copilot Memory: Repository Facts & User Preferences](docs/copilot-memory.md)** — How Copilot learns repository patterns and user preferences. Storage, retention, validation, and organizational best practices.

**Security & Code Analysis:**
- **[CodeQL Database Preparation](docs/codeql/01-database-preparation.md)** — Complete guide to installing CodeQL CLI, creating databases, and understanding extractors.
- **[Running CodeQL Queries](docs/codeql/02-run-queries.md)** — Running analyses, understanding results, uploading to GitHub, and integrating with CI/CD.

View the full documentation: **[GitHub Pages](https://github.com/YOUR-ORG/gh-certifications/wiki)** (after deployment)

## 🚀 Quick Start

### View the Guides

All guides are in the `docs/` folder and published to GitHub Pages. Start with:

```bash
# View CodeQL guide locally
open docs/codeql/01-database-preparation.md
```

### Create Your First CodeQL Database

```bash
# 1. Install CodeQL CLI (see guide for details)
# 2. Navigate to your project
cd your-project

# 3. Create a database
codeql database create ./codeql-db --language=javascript

# 4. Verify
codeql database info ./codeql-db
```

## 📋 Contents

```
docs/
├── index.md                 # Main documentation hub
├── _config.yml              # GitHub Pages configuration
└── codeql/
    └── 01-database-preparation.md  # CodeQL CLI setup and database creation
```

## 🔗 Resources

- [CodeQL Documentation](https://codeql.github.io/docs/)
- [GitHub Code Scanning](https://docs.github.com/en/code-security/code-scanning)
- [GitHub Security Lab](https://securitylab.github.com/)

## 📝 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## ✨ Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for suggestions.

---

**Last Updated:** May 2026
