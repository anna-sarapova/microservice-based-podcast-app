FROM elixir:1.13.2

RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /auth_service
ADD . .

RUN mix deps.get && \
    mix deps.compile && \
    mix clean && mix deps.clean --unused

CMD ["iex", "-S", "mix", "run"]
EXPOSE 8080