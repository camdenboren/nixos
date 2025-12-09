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
      tunnel_protocol = "wireguard";
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
      };
      openvpn_constraints = {
        port = "any";
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
  bridge_state = "auto";
  custom_lists = {
    custom_lists = [ ];
  };
  api_access_methods = {
    direct = {
      id = "6acec7e9-9b36-4f08-87da-5e5f7bc8358d";
      name = "Direct";
      enabled = true;
      access_method = {
        built_in = "direct";
      };
    };
    mullvad_bridges = {
      id = "98dfb829-a241-4ef5-baf0-b10b6cec28ec";
      name = "Mullvad Bridges";
      enabled = true;
      access_method = {
        built_in = "bridge";
      };
    };
    encrypted_dns_proxy = {
      id = "46f628aa-8b36-46f6-8748-2896817a0b24";
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
      quantum_resistant = "auto";
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
  settings_version = 12;
  recents = [ ];
  rollout_threshold_seed = 738145885;
}
