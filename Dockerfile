FROM xueshanf/awscli

RUN apk add --update \
    zip \
    git \
  && rm -rf /var/cache/apk/*

ADD scripts/start-build /usr/local/bin
ADD scripts/codepipeline /usr/local/bin

# backward compatibility
RUN ln -s /usr/local/bin/start-build /usr/local/bin/codebuild
