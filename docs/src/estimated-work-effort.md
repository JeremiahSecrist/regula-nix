# Estimated Work Effort

# Quality Teirs

 - High:
    - Estimated Hours:
    - Of standard to be merged upstream.
    - Fully functional.
    - well documented.
 - Medium:
    - Usable as a flake.
    - fully functional but needs refactoring potentially.
    - mostly documented.
 - Low:
    - Proof of concept stage.
    - Missing features.
    - Light documentation.

# Project Stages

## Community feedback

During this stage we would take a well defined UX and interface documentation and share it with the nix comunity to gage interest and seek user feedback.

## Writing The Module

This covers created the nixos module that implements the features mentioned in deliverables.

## Documentation

We document both the implementation and usage to encorage contribution to the project.

## Upstreaming

Working with official nixos maintainers to upstream this project making any adjustments needed.

## Porting Existing Security Standards

Taking projects such as stigs, CIS Benchmark, etc. and porting them over to this implementation.

# Deliverables

 - A nixos module that enables users to easily create and define security specification
 - Exposes interfaces to check at the following times of the build process:
    - Evaluation time: when nix is resolving the configuration.
    - Build time: when required custom check dependencies are being built.
    - Top level build: time when the final system is being assembled.
    - Virutalized test of the system with python.
