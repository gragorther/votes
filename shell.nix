with import <nixpkgs> {}; # This should probably be pinned to something. For me it points to 24.05 channel
let
  basePackages = [
    beam29Packages.elixir_1_20
    beam29Packages.erlang
    elixir-ls
    inotify-tools
    nodejs
    yarn
    postgresql
    process-compose
  ];
  PROJECT_ROOT = builtins.toString ./.;

  hooks = ''
    mkdir -p .nix-mix
    mkdir -p .nix-hex
    export MIX_HOME=${PROJECT_ROOT}/.nix-mix
    export HEX_HOME=${PROJECT_ROOT}/.nix-hex
    export PATH=$MIX_HOME/bin:$PATH
    export PATH=$HEX_HOME/bin:$PATH
    export LANG=en_NZ.UTF-8
    export ERL_AFLAGS="-kernel shell_history enabled"

    
    export PGDIR=${PROJECT_ROOT}/postgres
    export PGHOST=$PGDIR
    export PGDATA=$PGDIR/data
    export PGLOG=$PGDIR/log
    export DATABASE_URL="postgresql:///postgres?host=$PGDIR"
    export PRIVATE_KEY=$(mix compile --no-all-warnings && mix eval --no-compile "IO.write Votes.Crypto.create_rsa_private_key() |> Votes.Crypto.pem_encode_rsa_private_key")
    if test ! -d $PGDIR; then
      mkdir $PGDIR
    fi

    export BASE_URL=http://localhost:4000/

   if [ ! -d $PGDATA ]; then
     echo 'Initializing postgresql database...'
     initdb $PGDATA --auth=trust >/dev/null
   fi

    '';

  in mkShell {
    buildInputs = basePackages;
    shellHook = hooks;
  }