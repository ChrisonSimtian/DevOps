# Tests/Public/Get-ExistingAuthorizationRule.Tests.ps1

Describe "Get-ExistingAuthorizationRule" {

    BeforeAll {
        # Import the module or dot-source the function if needed
        . "$PSScriptRoot\..\..\Public\Get-ExistingAuthorizationRule.ps1"
        $ResourceGroup = "mfb-erp-ae-test"
        $Namespace = "mfb-sb-ae-test"
        $PolicyName = "mb-manage"
        $EntityName = "ErpBodMessages"
    }

    Context "When IsQueue is specified" {
        It "Returns the authorization rule for a queue" {
            Mock Connect-AzAccount {}
            Mock Get-AzServiceBusAuthorizationRule {
                return @{ Name = "MyPolicy"; Rights = @("Listen", "Send") }
            }

            $result = Get-ExistingAuthorizationRule -ResourceGroup $ResourceGroup -Namespace $Namespace -PolicyName $PolicyName -EntityName $EntityName -IsQueue

            $result.Name | Should -Be "MyPolicy"
            $result.Rights | Should -Contain "Send"
        }
    }

    Context "When IsTopic is specified" {
        It "Returns the authorization rule for a topic" {
            Mock Connect-AzAccount {}
            Mock Get-AzServiceBusAuthorizationRule {
                return @{ Name = "MyPolicy"; Rights = @("Manage") }
            }

            $result = Get-ExistingAuthorizationRule -ResourceGroup $ResourceGroup -Namespace $Namespace -PolicyName $PolicyName -EntityName "MyTopic" -IsTopic

            $result.Name | Should -Be "MyPolicy"
            $result.Rights | Should -Contain "Manage"
        }
    }

    Context "When no rule is found" {
        It "Returns null" {
            Mock Connect-AzAccount {}
            Mock Get-AzServiceBusAuthorizationRule { return $null }

            $result = Get-ExistingAuthorizationRule -ResourceGroup $ResourceGroup -Namespace $Namespace -PolicyName "MissingPolicy" -EntityName $EntityName -IsQueue

            $result | Should -Be $null
        }
    }

    Context "When neither IsQueue nor IsTopic is specified" {
        It "Returns rule scoped to namespace" {
            Mock Connect-AzAccount {}
            Mock Get-AzServiceBusAuthorizationRule {
                return @{ Name = "NamespacePolicy"; Rights = @("Listen") }
            }

            $result = Get-ExistingAuthorizationRule -ResourceGroup $ResourceGroup -Namespace $Namespace -PolicyName "NamespacePolicy"

            $result.Name | Should -Be "NamespacePolicy"
            $result.Rights | Should -Contain "Listen"
        }
    }
}
