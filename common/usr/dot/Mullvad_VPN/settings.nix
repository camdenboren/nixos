{ hostname, ... }:

{
  relay_settings = {
    normal = {
      location = {
        only = {
          location = {
            city = [
              "us"
              "dal"
            ];
          };
        };
      };
      providers = "any";
      ownership = "any";
      wireguard_constraints = {
        port = "any";
        ip_version = "any";
        allowed_ips = "any";
        use_multihop = false;
        entry_location = {
          only = {
            location = {
              country = "se";
            };
          };
        };
        entry_providers = "any";
        entry_ownership = "any";
      };
    };
  };
  bridge_settings = {
    bridge_type = "normal";
    normal = {
      location = "any";
      providers = "any";
      ownership = "any";
    };
    custom = null;
  };
  obfuscation_settings = {
    selected_obfuscation = "auto";
    udp2tcp = {
      port = "any";
    };
    shadowsocks = {
      port = "any";
    };
  };
  custom_lists = {
    custom_lists = [ ];
  };
  api_access_methods = {
    direct = {
      id = "5dda2926-ee0f-4efe-89fb-4701e000b8af";
      name = "Direct";
      enabled = true;
      access_method = {
        built_in = "direct";
      };
    };
    mullvad_bridges = {
      id = "a394d202-ba0c-46d4-9e48-83e3d1381d3b";
      name = "Mullvad Bridges";
      enabled = true;
      access_method = {
        built_in = "bridge";
      };
    };
    encrypted_dns_proxy = {
      id = "fa5a434d-19c5-4693-ae43-b7747315255d";
      name = "Encrypted DNS proxy";
      enabled = true;
      access_method = {
        built_in = "encrypted_dns_proxy";
      };
    };
    custom = [ ];
  };
  update_default_location = false;
  allow_lan = true;
  lockdown_mode = false;
  auto_connect = (hostname == "main");
  tunnel_options = {
    openvpn = {
      mssfix = null;
    };
    wireguard = {
      mtu = null;
      quantum_resistant = "on";
      daita = {
        enabled = false;
        use_multihop_if_necessary = true;
      };
      rotation_interval = null;
    };
    generic = {
      enable_ipv6 = true;
    };
    dns_options = {
      state = "default";
      default_options = {
        block_ads = true;
        block_trackers = true;
        block_malware = true;
        block_adult_content = true;
        block_gambling = true;
        block_social_media = true;
      };
      custom_options = {
        addresses = [ ];
      };
    };
  };
  relay_overrides = [ ];
  show_beta_releases = false;
  settings_version = 13;
  recents = [ ];
  rollout_threshold_seed = 1644152406;
}
