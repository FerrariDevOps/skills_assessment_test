# Skills assessment test

Firstly, I would like to thank you for the opportunity to take this test, it has been great fun, since it deals with some scenarios I have not worked with for some time, HSM being one example.
I also don't have hands on experience with GitLab, so scenario 3 turned into a proper journey through its documentation, and I enjoyed every bit of it.

This repository holds my answers to the Cloud DevOps Engineer skills assessment, four scenarios covering AWS KMS key rotation, public and private API exposure, GitLab resilience and monitoring, and an AWS Backup policy built as a Terraform module.

Each scenario has its own folder with an `ANSWER.MD` file, and scenario 4 also carries the working Terraform module referenced in its answer.

- [Scenario 1, KMS key rotation](scenario-1/ANSWER.MD)
- [Scenario 2, public and private APIs](scenario-2/ANSWER.MD)
- [Scenario 3, GitLab resilience and monitoring](scenario-3/ANSWER.MD)
- [Scenario 4, backup policy with AWS Backup (Terraform module)](scenario-4/ANSWER.MD)

## LLM usage

I used Claude Sonnet 5 as an AI assistant throughout this test, for formatting text, checking grammar, creating diagrams and running lint checks on the Markdown and Terraform files.

The [`.claude/skills`](.claude/skills/README.md) folder lists the skills behind that workflow, both the official Anthropic ones and a couple of illustrative community examples.
