# Contributing to WeAura Terraform Modules

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing.

## Code of Conduct

Please be respectful and constructive in all interactions. We are committed to providing a welcoming and inclusive experience for everyone.

## How to Contribute

### Reporting Issues

Before creating an issue, please:

1. Search existing issues to avoid duplicates
2. Use the appropriate issue template
3. Provide as much context as possible

### Suggesting Features

1. Open a feature request issue
2. Describe the use case and expected behavior
3. Explain why this would benefit the community

### Submitting Pull Requests

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes
4. Ensure all tests pass
5. Submit a pull request

## Development Guidelines

### Prerequisites

- Terraform >= 1.5.0
- TFLint
- terraform-docs
- Pre-commit (optional but recommended)

### Code Style

#### Terraform Files

- Use `terraform fmt` to format all files
- Follow [Terraform style conventions](https://developer.hashicorp.com/terraform/language/syntax/style)
- Use meaningful variable and resource names
- Add descriptions to all variables and outputs

#### File Naming

```
versions.tf      # Provider and version requirements
variables.tf     # Input variables
locals.tf        # Local values
main.tf          # Main resources (or split by resource type)
outputs.tf       # Output values
```

For multi-cloud modules:

```
aws_*.tf         # AWS-specific resources
azure_*.tf       # Azure-specific resources
```

#### Variables

```hcl
variable "example" {
  description = "Description of the variable"
  type        = string
  default     = "default_value"  # Optional

  validation {
    condition     = length(var.example) > 0
    error_message = "Example must not be empty."
  }
}
```

#### Resources

- Use consistent naming: `resource_type.name`
- Add `count` or `for_each` for conditional resources
- Group related resources together

### Testing

Before submitting:

```bash
# Format check
terraform fmt -check -recursive

# Validate all modules
for module in modules/*/; do
  cd "$module"
  terraform init -backend=false
  terraform validate
  cd -
done

# Lint
tflint --recursive
```

### Documentation

- Update module README.md with any new variables/outputs
- Add examples for new features
- Use terraform-docs for generating documentation:

```bash
terraform-docs markdown table --output-file README.md --output-mode inject modules/grafana-oss/
```

### Commit Messages

Follow conventional commits:

```
feat: add Azure support for grafana-oss module
fix: correct S3 bucket policy for Loki
docs: update README with Azure examples
chore: update provider versions
```

Types:

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `chore`: Maintenance tasks
- `refactor`: Code refactoring
- `test`: Adding or updating tests

## Pull Request Process

1. **Title**: Use conventional commit format
2. **Description**: Explain what and why
3. **Checklist**:
   - [ ] Code is formatted (`terraform fmt`)
   - [ ] All modules validate successfully
   - [ ] Documentation is updated
   - [ ] Examples are updated if needed
   - [ ] No sensitive data is committed

4. **Review**: Wait for maintainer review
5. **Merge**: Maintainers will merge after approval

## Module Structure

Each module should follow this structure:

```
modules/module-name/
├── README.md              # Module documentation
├── versions.tf            # Provider requirements
├── variables.tf           # Input variables
├── locals.tf              # Local values
├── main.tf                # Main resources
├── outputs.tf             # Outputs
├── templates/             # Template files
└── examples/              # Usage examples
    ├── minimal/
    ├── aws-complete/
    └── azure-complete/
```

## Questions?

If you have questions, feel free to:

- Open a discussion issue
- Reach out to maintainers

Thank you for contributing!
