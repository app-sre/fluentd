FROM registry.access.redhat.com/ubi9/ruby-33@sha256:392fbfb676067523b991e2b6cfe2f5469daa8989ab69a89a0b42dd5d3ac5e8f3 AS base
# keep in sync with fluentd in Gemfile
LABEL konflux.additional-tags="1.16.1"
COPY LICENSE /licenses/LICENSE

FROM base as builder
WORKDIR /opt/app-root/src
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment true \
    bundle config set --local path "vendor/bundle" \
    && bundle install \
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
