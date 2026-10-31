using Workerd = import "/workerd/workerd.capnp";

const config :Workerd.Config = (
  services = [
    (name = "main", worker = .mainWorker),
  ],
  sockets = [
    (
      name = "http",
      address = "127.0.0.1:6000",
      http = (),
      service = "main",
    ),
  ],
);

const mainWorker :Workerd.Worker = (
  modules = [
    (name = "worker.js", esModule = embed "worker.js"),
  ],
  bindings = [
    (name = "API_KEY", fromEnvironment = "API_KEY"),
  ],
  compatibilityDate = "2026-10-29",
);
