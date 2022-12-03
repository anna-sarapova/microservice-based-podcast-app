FROM elixir:1.13.2

RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /auth_service3
ADD . .

RUN mix deps.get && \
    mix deps.compile && \
    mix clean && mix deps.clean --unused

CMD ["mix", "run", "--no-halt"]
EXPOSE 8082