class PaJob {
    [int]$Id
    [DateTime]$Enqueued
    [DateTime]$Dequeued
    [string]$Type
    [string]$Status
    [string]$Result
    [DateTime]$TimeComplete
    [string]$Warnings
    [string]$Details
    [string]$Description
    [string]$User
    [string]$Progress

    ##################################### Initiators #####################################
    # Initiator
    PaJob([int]$JobId) {
        $this.Id = $JobId
    }
}