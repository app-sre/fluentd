FROM registry.access.redhat.com/ubi9/ruby-33@sha256:32759542bc482c80c16964663d9410a33f0e704cc14a459a6f1b2691abdeb6a0 AS base
# keep in sync with fluentd in Gemfile
LABEL konflux.additional-tags="1.16.1"
COPY LICENSE /licenses/LICENSE

FROM base as builder
WORKDIR /opt/app-root/src
# https://github.com/sowawa/fluent-plugin-slack/pull/58
COPY Gemfile Gemfile.lock fluent-plugin-slack-pull-58.patch ./
RUN bundle config set --local deployment true \
    bundle config set --local path "vendor/bundle" \
    && bundle install \
    && patch -d ./vendor/bundle/ruby/3.3.0/gems/fluent-plugin-slack-0.6.7 -p1 < fluent-plugin-slack-pull-58.patch \
    && rm -rf .bundle/cache vendor/bundle/ruby/*/cache
RUN bundle exec fluentd --setup fluentd --setup ./fluent

FROM base as prod
WORKDIR /opt/app-root/src
COPY --from=builder --chown=1001:0 /opt/app-root/src .
USER 0
RUN mkdir -p /fluentd/log /fluentd/etc /fluentd/plugins \
    && cp /opt/app-root/src/fluent/fluent.conf /fluentd/etc/fluent.conf \
    && chown -R 1001:0 /fluentd
USER 1001
CMD ["bundle", "exec", "fluentd", "-c", "/fluentd/etc/fluent.conf"]
