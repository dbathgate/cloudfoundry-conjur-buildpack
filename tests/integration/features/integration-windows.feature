@integration-windows
Feature: Integrations Tests for remote TAS foundation with Windows

  These tests verify how the windows support of the buildpack
  works on Cloud Foundry.

  # Our CI pipeline does not support Windows buildpacks. This can
  # be tested locally against a TAS environment that supports Windows.
    
    Background:
      Given I create an org and space
      And I install the buildpack

    Scenario: Dotnet offline windows buildpack integration
      When I push a "dotnet-windows" app with the "offline" buildpack
      Then the secrets.yml values are available in the app