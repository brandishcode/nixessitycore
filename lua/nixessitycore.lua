local nixessitycore = {}

function nixessitycore:flake_output(flake_path)
  return os.execute(
    'nix eval --expr \'builtins.attrNames (builtins.getFlake "path:'
      .. flake_path
      .. '").outputs.packages.${builtins.currentSystem}\' --impure --json'
  )
end

return nixessitycore
