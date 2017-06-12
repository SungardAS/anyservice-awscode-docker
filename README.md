# anyservice-awscode

Integrate AWS CodeBuild and Pipelines with git services

## Compatible Providers

* BitBucket
* GitLab

**Image**: [Docker Hub][dockerhub-url]

## CodeBuild

This image will create a zip archive of the project, send it to a `CODEBUILD_S3_BUCKET`/`CODEBUILD_S3_KEY` location and start a new AWS CodeBuild build process.  The build process will be tied to the version of the archive in S3.

Bitbucket Pipelines will wait for AWS CodeBuild to finish and respectively retrun success or failure based on the outcome of the build.

### bitbucket-pipelines.yml
```
image: sungardas/bitbucket-awscode
pipelines:
  default:
    - step:
        script:
            - |
              AWS_DEFAULT_REGION=us-east-1 \
              CODEBUILD_S3_BUCKET=my-s3-bucket-name \
              CODEBUILD_S3_ARCHIVE_KEY=codebuild/project-name/code.zip \
              CODEBUILD_S3_MAP_PATH=codebuild/project-name/bitbucketmap \
              CODEBUILD_START_JSON_FILE=cicd/buildspec/start_build.json \
              start-build

```


## AWS Pipeline

Once a successful build has completed an AWS Pipeline can be executed as a Bitbucket Custom Pipeline from the respective commit. The artifact(s) produced by AWS CodeBuild will be fetched.  If the artificats are not already in a zip archive they will be put in one and uploaded to the pipeline bucket and key path.

### bitbucket-pipelines.yml
```
image: sungardas/bitbucket-awscode
pipelines:
  custom:
    pipeline_release:
      - step:
          script:
            - env
            - |
              AWS_DEFAULT_REGION=us-east-1 \
              CODEBUILD_S3_BUCKET=my-s3-bucket-name \
              CODEBUILD_S3_MAP_PATH=codebuild/project-name/bitbucketmap \
              CODEPIPELINE_S3_BUCKET=my-pipeline-s3-bucket \
              CODEPIPELINE_S3_ARCHIVE_KEY=codepipeline/project-name/pipeline.zip \
              codepipeline
```



## Environment Variables

It is recommened keep all configuraiton in `bitbucket-pipelines.yml` except for `AWS_ACCESS_KEY_ID` and the `AWS_SECRET_ACCESS_KEY`. That will ensure a commit is always associated with the corresponding S3 buckets and paths.

### `AWS_ACCESS_KEY_ID`
**required**

The AWS Access Key for the User who will start the build

### `AWS_SECRET_ACCESS_KEY`
**required**

The AWS Secret Access key for the User who will start the build

### `AWS_DEFAULT_REGION`
**required**

The region AWS CodeBuild will be executed in

### `CODEBUILD_S3_BUCKET`
**required**

The S3 bucket AWS CodeBuild will use to pull the code archive

### `CODEBUILD_S3_ARCHIVE_KEY`
**required**

The S3 key AWS CodeBuild will use to pull the code archive

**Example**
`codebuild/my-project/my-code.zip`

### `CODEBUILD_START_JSON_FILE`
**optional**

Full path to a JSON file within the project that will be merged and added to the `start-build` CodeBuild command.

**Example**
`cicd/buildspec/start_build.json`

### `CODEBUILD_PROJECT_NAME`
**optional**

The name of the AWS CodeBuild Project. If not set here, this must be defined in `CODEBUILD_START_JSON_FILE`

### `CODEBUILD_S3_MAP_PATH`
**optional**

If set and the build is a success this will store a file for every
git commit containing the most recent AWS CodeBuild ID.

Useful for custom BitBucket Pipelines.

**Example**
`codebuild/my-project/bitbucketmap`

**Example Bucket Structure**
```
- codebuild
-- my-project
--- bitbucketmap
---- BITBUCKETUSER-REPONAME-GITSHA
---- ...
```

### `WAIT_FOR_CODEBUILD=[true]`
If `true` then Bitbucket Pipelines will wait for AWS CodeBuild to
finish. If the build fails then so will the pipeline in Bitbucket.

---



[dockerhub-url]: https://hub.docker.com/r/sungardas/bitbucket-awscode/
