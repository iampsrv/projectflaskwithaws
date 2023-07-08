resource "aws_codecommit_repository" "code_commit_repo" {
  repository_name = var.code_commit_repo
  description     = "This is the Code commit Repository created by terraform"
}

resource "aws_codebuild_project" "my_project" {
  name           = "projectbatchfive-tf"
  description    = "This code build project is created by terraform"
  build_timeout  = "60"
  queued_timeout = "480"

  service_role = "arn:aws:iam::633423483143:role/project_codebuild_batchfive"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type = "NO_CACHE"

  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = "mycodebuildlogs"
      stream_name = "mycodebuildlogs-stream"
    }

    s3_logs {
      status              = "ENABLED"
      location            = "iampsbucket/cb-tf"
      encryption_disabled = false
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/codecommit-tf-batchfive"
    git_clone_depth = 1
    buildspec       = file("buildspec.yml")
  }

}

resource "aws_codepipeline" "codepipeline" {
  name     = "projectbatchfivepipeline-tf"
  role_arn = "arn:aws:iam::633423483143:role/service-role/code-pipeline"

  artifact_store {
    location = aws_s3_bucket.pipline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        "PollForSourceChanges" = "false",
        "RepositoryName"       = "codecommit-tf-batchfive",
        "BranchName"           = "master",
        "OutputArtifactFormat" = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.my_project.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["BuildArtifact"]
      version         = "1"

      configuration = {
        ClusterName = "my-batchfivecluster",
        ServiceName = "mysvc",
        FileName    = "imagedefinitions.json"
      }
    }
  }
}
