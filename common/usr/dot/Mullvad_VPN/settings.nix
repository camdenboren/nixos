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
        ip_version = "any";
        allowed_ips = "any";
        use_multihop = false;
        entry_location = {
          only = {
            location = {
              country = "us";
            };
          };
        };
        entry_providers = "any";
        entry_ownership = "any";
      };
    };
  };
  obfuscation_settings = {
    selected_obfuscation = "auto";
    lwo = {
      port = "any";
    };
    udp2tcp = {
      port = "any";
    };
    shadowsocks = {
      port = "any";
    };
    wireguard_port = {
      port = "any";
    };
  };
  custom_lists = {
    custom_lists = [ ];
  };
  api_access_methods = {
    direct = {
      id = "4f2a3a41-3e37-4516-bf8c-792a1f94578f";
      name = "Direct";
      enabled = true;
      access_method = {
        built_in = "direct";
      };
    };
    mullvad_bridges = {
      id = "83de3353-fcb6-4d41-98d3-54bc36ce5921";
      name = "Mullvad Bridges";
      enabled = true;
      access_method = {
        built_in = "bridge";
      };
    };
    encrypted_dns_proxy = {
      id = "28bc46fc-fcb3-4559-8fdf-1f58381f577b";
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
  auto_connect = hostname == "main";
  tunnel_options = {
    wireguard = {
      mtu = null;
      quantum_resistant = "on";
      daita = {
        enabled = false;
        use_multihop_if_necessary = true;
      };
      rotation_interval = null;
      userspace = false;
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
  settings_version = 15;
  recents = [ ];
  rollout_threshold_seed = 3738083069;
}
