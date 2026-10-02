{ config, ... }:

let
  baseDomain = "home.local";
  dexURL = "https://dex.${baseDomain}";
  outlineURL = "https://notes.${baseDomain}";
in
{
  services.outline = {
    enable = true;
    forceHttps = false;
    publicUrl = outlineURL;
    storage.storageType = "local";
    oidcAuthentication = {
      authUrl = "${dexURL}/auth";
      tokenUrl = "${dexURL}/token";
      userinfoUrl = "${dexURL}/userinfo";
      clientId = "outline";
      clientSecretFile = (builtins.elemAt config.services.dex.settings.staticClients 0).secretFile;
      scopes = [
        "openid"
        "email"
        "profile"
        "offline_access"
      ];
      usernameClaim = "preferred_username";
      displayName = "Dex";
    };
  };

  services.dex = {
    enable = true;

    settings = {
      issuer = dexURL;
      storage = {
        type = "sqlite3";
        # persists refresh_tokens on disk to prevent logging users out during
        # daily server shutdowns. also requires setting `StateDirectory` for
        # the systemd unit
        config.file = "/var/lib/dex/dex.db";
      };
      web.http = "127.0.0.1:5556";
      enablePasswordDB = true;
      staticClients = [
        {
          id = "outline";
          name = "Outline Client";
          redirectURIs = [ "${outlineURL}/auth/oidc.callback" ];
          secretFile = "/var/lib/secrets/dex";
        }
      ];
      staticPasswords = [
        {
          email = "9UtEfABpSSrV3g.code@mailbox.org";
          # requires $(shell apacheHttpd)
          # bcrypt hash of the password: $(echo password | htpasswd -BinC 10 admin | cut -d: -f2)
          hash = "$2y$10$MuAnLgehPp6RvRQk/cfmruEQglQURoVNEOt99Sh1VqlVnUKQQdmV6";
          username = "admin";
          # easily generated with `$ uuidgen`
          userID = "6D196B03-8A28-4D6E-B849-9298168CBA34";
        }
      ];
    };
  };

  # allow self-signed certs via adding NODE_TLS_REJECT_UNAUTHORIZED
  systemd.services.outline.serviceConfig.Environment = "NODE_TLS_REJECT_UNAUTHORIZED=0";

  # create the database directory for dex to enable persisting `refresh_token`
  systemd.services.dex.serviceConfig.StateDirectory = "dex";
}
