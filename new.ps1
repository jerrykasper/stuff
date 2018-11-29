Param (
    $gateway,
    $node
)
Begin {}
Process {

    $gatewayObject = Get-ADComputer -Identity $gateway
    $nodeObject = Get-ADComputer -Identity $node
    Set-ADComputer -Identity $nodeObject -PrincipalsAllowedToDelegateToAccount $gatewayObject

}
End {

}