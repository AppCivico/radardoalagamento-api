{
  name  => 'Tupa::Web::App',
  model => {
    DB => {
      connect_info => {
        dsn            => 'dbi:Pg:dbname=tupa-dev;host=127.0.0.1;port=5432',
        user           => 'postgres',
        AutoCommit     => 1,
        quote_char     => q{"},
        name_sep       => q{.},
        pg_enable_utf8 => 1,
        auto_savepoint => 1,
        on_connect_do  => ['SET client_encoding=UTF8', q{SET timezone = 'UTC'}]
      }
    }
  },
  plugin => {
    Authentication => {
      default_realm => 'default',
      realms        => {
        default => {
          credential => {
            class          => 'Password',
            password_field => 'password',
            password_type  => 'self_check'
          },
          store => {
            class         => 'DBIx::Class',
            user_model    => 'DB::User',
            role_relation => 'roles',
            role_field    => 'name'
          }
        }
      }
    }
  }
}
