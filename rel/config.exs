use Mix.Releases.Config,
  default_release: :default,
  default_environment: :default

environment :default do
#  set(pre_start_hook: "bin/hooks/pre-start.sh")
  set(dev_mode: false)
  set(include_erts: true)
  set(include_src: false)

  set(
    overlays: [
      {:template, "rel/templates/vm.args.eex", "releases/<%= release_version %>/vm.args"}
    ]
  )
end

release :mobile_api do
  set(version: current_version(:mobile_api))
  set applications: [
    mobile_api: :permanent
  ]
end

release :attestation_api do
  set(version: current_version(:attestation_api))
  set applications: [
    attestation_api: :permanent
  ]
end