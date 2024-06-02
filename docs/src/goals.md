# Goals

- Low complexity for the end user.
- High configurability for security profile developers.
- Traceable to both the source code and security profile documentation.
- Provable enforcement (We can't tamper with settings downstream).

## Methods
These methods are ideas minus the first one which is known to be obtainable.

1. Using Assertions and Warnings via nixos built int intergration tests.
    - Pros: Catch's errors at eval time vs system run time.
    - Cons: 
        - Does not account for custom modules outside of nixpkgs. 
        - Strictly bound to nixos.
2. A shell script that is assembled via the nix language.
    - Pros: It's lightweight and can be made to run on non nix systems.
    - Cons: It's yet another shell script.
3. Systemd service that verifies after startup.
    - Pros: We could fail the startup of a system that does not meet standards.
    - Cons: more integral with the nixos systems at play and less portable. 
4. Remote server that conencts to preform the external audit.
    - Pros:
        - Very difficult to tamper with.
        - Centralised deployment.
        - could audit non nix systems.
    - Cons: 
        - Disconeccted from the build process.