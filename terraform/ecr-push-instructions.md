********# ECR Push Instructions

## 1. ECRにログイン
```bash
aws ecr get-login-password | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$(aws configure get region).amazonaws.com
```

## 2. ローカルイメージをビルド（Dockerfileがある場合）
```bash
docker build -t laravel-app .
```

## 3. ECRリポジトリ用にタグ付け
```bash
docker tag laravel-app:latest $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$(aws configure get region).amazonaws.com/laravel-app:latest
```

## 4. ECRにプッシュ
```bash
docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$(aws configure get region).amazonaws.com/laravel-app:latest
```

## 2,3,4ワンライナー版
```bash
docker build -t laravel-app . && docker tag laravel-app:latest $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$(aws configure get region).amazonaws.com/laravel-app:latest && docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$(aws configure get region).amazonaws.com/laravel-app:latest
```