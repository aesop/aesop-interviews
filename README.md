# Aesop Interviews 

TBD

## Development

### Prerequisites

1. Wing `npm install -g winglang` and `wing --version`
2. Wing VSCode extension
3. Docker
4. Terraform CLI
5. AWS CLI and SSO setup

#### Install

```bash
npm ci
```

### Running solution locally

`npm start` or `wing it`

## Deployment

To compile and deploy with Terraform:

1. Setup an SSO profile for AWS for the interviews account. The profile name should be `interviews`. e.g. ( run `aws sso login --profile interviews`)
2. Setup Terraform state file after navigating to the relevant folder under `target`. This may require running `npm run compile` first to generate the folder

    ```bash
    npm run compile
    cd target/interviews.main.tfaws
    terraform init
    ```

3. Deploy

    ```bash
    npm run compile
    cd target/interviews.main.tfaws
    terraform plan
    terraform apply
    cd ../../
    ```
