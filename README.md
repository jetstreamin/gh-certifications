# GitHub Certifications Learning Repository

A comprehensive learning hub for GitHub security and advanced topics certifications, with step-by-step guides, quick references, and verified best practices.

## 📖 Documentation

**Exam Certifications:**

- **[GH-600: Developing in Agentic AI Systems](docs/gh-600-exam-guide.md)** — Complete study guide for the Microsoft Certified: GitHub Agentic AI Developer exam. Covers all 6 skill areas with practical patterns and implementation examples.
- **[GH-600 Hard Practice Tests](docs/gh-600-practice-tests.md)** — Two difficult practice tests with answer keys, scoring guidance, and a fast-pass checklist.
- **[GH-600 Native Mock Exam](docs/gh-600-native-mock-exam.html)** — Native browser mock exam with 60 timed questions, automatic scoring, study mode, flash cards, keyboard shortcuts, read-aloud mode, and correct-answer reveal.

**Agent Administration, SDK, Memory & Tutorials:**

- **[Custom Agents Administration Guide](docs/custom-agents-admin-guide.md)** — Setup and governance for organization-level custom Copilot agents. Repository structure, compliance, security, and lifecycle management.
- **[Cloud Agent Guardrails](docs/cloud-agent-guardrails.md)** — Guardrails for GitHub Copilot cloud agent. Policy planning, rulesets, Actions secrets, runners, and workflow protections.
- **[Cloud Agent Risks and Mitigations](docs/cloud-agent-risks-mitigations.md)** — Risks and built-in mitigations for GitHub Copilot cloud agent. Code validation, repository writes, sensitive data, prompt injection, and auditing.
- **[Copilot SDK: Custom Agents Implementation](docs/copilot-sdk-custom-agents.md)** — Developer guide for building custom agents with the Copilot SDK. Configuration, event handling, tool scoping, and production patterns.
- **[Copilot Memory: Repository Facts & User Preferences](docs/copilot-memory.md)** — How Copilot learns repository patterns and user preferences. Storage, retention, validation, and organizational best practices.
- **[Custom Agent: Implementation Planner](docs/custom-agent-implementation-planner.md)** — Tutorial for creating a custom agent that breaks down features into actionable tasks and creates detailed implementation plans.

**Security & Code Analysis:**

- **[CodeQL Database Preparation](docs/codeql/01-database-preparation.md)** — Complete guide to installing CodeQL CLI, creating databases, and understanding extractors.
- **[Running CodeQL Queries](docs/codeql/02-run-queries.md)** — Running analyses, understanding results, uploading to GitHub, and integrating with CI/CD.

**📌 View all guides:** [Full Documentation Hub](https://jetstreamin.github.io/gh-certifications/) (GitHub Pages)

## 🚀 Quick Start

### View the Guides Locally

All guides are in the `docs/` folder. Start with:

```bash
# View any guide
cat docs/gh-600-exam-guide.md
cat docs/gh-600-practice-tests.md
cat docs/gh-600-native-mock-exam.html
cat docs/copilot-sdk-custom-agents.md
cat docs/custom-agent-implementation-planner.md
```

### View on GitHub Pages

Visit: [GitHub Pages](https://jetstreamin.github.io/gh-certifications/)

## 📋 Repository Structure

```text
.
├── README.md                              # This file
├── LICENSE                                # MIT License
├── .github/
│   └── workflows/
│       └── public-pages.yml              # GitHub Pages auto-deployment
├── docs/
│   ├── index.md                           # Documentation hub
│   ├── _config.yml                        # Jekyll configuration
│   ├── gh-600-exam-guide.md               # GH-600 certification guide
│   ├── gh-600-practice-tests.md           # GH-600 practice tests
│   ├── gh-600-native-mock-exam.html       # GH-600 native timed mock exam
│   ├── custom-agents-admin-guide.md       # Organization administration
│   ├── cloud-agent-guardrails.md          # Cloud agent guardrails tutorial
│   ├── cloud-agent-risks-mitigations.md    # Cloud agent risks and mitigations
│   ├── copilot-sdk-custom-agents.md       # SDK implementation guide
│   ├── copilot-memory.md                  # Memory facts & preferences
│   ├── custom-agent-implementation-planner.md  # Implementation planner agent
│   └── codeql/
│       ├── 01-database-preparation.md     # CodeQL database setup
│       └── 02-run-queries.md              # CodeQL query execution
```

## 🔗 Resources

- **GitHub Copilot Documentation:** [docs.github.com/en/copilot](https://docs.github.com/en/copilot)
- **CodeQL Documentation:** [codeql.github.io/docs](https://codeql.github.io/docs/)
- **GitHub Code Scanning:** [docs.github.com/en/code-security/code-scanning](https://docs.github.com/en/code-security/code-scanning)
- **GitHub Security Lab:** [securitylab.github.com](https://securitylab.github.com/)
- **Awesome GitHub Copilot Customizations:** [github.com/github/awesome-copilot/tree/main/agents](https://github.com/github/awesome-copilot/tree/main/agents)

## 📊 Coverage Summary

- GH-600 Exam: 3 guides, ~13,000 lines, complete
- Custom Agents (Admin): 1 guide, ~4,000 lines, complete
- Copilot SDK: 1 guide, ~7,200 lines, complete
- Copilot Memory: 1 guide, ~9,000 lines, complete
- Custom Agent: Planner: 1 guide, ~5,000 lines, complete
- CodeQL: 2 guides, ~2,700 lines, complete
- Total: 13 guides, ~43,000 lines, complete

## 🛠️ Development & Contribution

### Build & Test Locally

```bash
# Clone the repository
git clone https://github.com/jetstreamin/gh-certifications.git
cd gh-certifications

# Install Jekyll (if not already installed)
gem install bundler jekyll

# Build Jekyll site
jekyll build

# Serve locally
jekyll serve
# Visit: http://localhost:4000/gh-certifications/
```

### GitHub Pages Configuration

The site is automatically deployed to GitHub Pages whenever commits are pushed to `main`:

- **Build Tool:** Jekyll
- **Theme:** jekyll-theme-minimal
- **Source:** `/docs` folder
- **URL:** [jetstreamin.github.io/gh-certifications](https://jetstreamin.github.io/gh-certifications/)
- **Workflow:** `.github/workflows/public-pages.yml`

### Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/enhancement`)
3. Make your changes
4. Commit with clear messages (`git commit -m 'docs: add new guide'`)
5. Push to your fork (`git push origin feature/enhancement`)
6. Open a pull request

### Guidelines

- Keep guides well-structured with clear sections
- Include code examples where applicable
- Add troubleshooting sections for complex topics
- Update this README if adding new guides
- Follow markdown best practices

## 📝 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## ✨ Acknowledgments

- GitHub Copilot Documentation Team
- GitHub CodeQL Team
- GitHub Security Lab
- Community contributors

---

**Last Updated:** May 18, 2026
**Repository:** [github.com/jetstreamin/gh-certifications](https://github.com/jetstreamin/gh-certifications)
**Pages:** [jetstreamin.github.io/gh-certifications](https://jetstreamin.github.io/gh-certifications/)
