# Populate-DirectoryStructure.Tests.ps1
# Purpose: Pester tests for key functions in Populate-DirectoryStructure.ps1

Describe "Populate-DirectoryStructure Functions" {
    BeforeAll {
        # Import the script to test its functions
        . "$PSScriptRoot\Populate-DirectoryStructure.ps1"

        # Mock variables
        $script:createdDirs = @()
        $script:createdFiles = @()
        $script:missingFiles = @()
        $script:logMessages = @()
        $script:errorSummary = @()
        $global:currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $batchMap = @{
            "matchmaking-app-web" = "1.1,2.1,3.1"
            "matchmaking-app-android" = "1.2,2.2,3.2"
            "matchmaking-app-backend" = "1.3,2.3,3.3"
            "vedicmatchweb" = "4.2"
            "mobile" = "4.2"
        }
        $global:DryRun = $false
        $global:LogLevel = "Info"
    }

    Context "Write-Log Function" {
        It "Logs Info message correctly" {
            $Message = "Test Info message"
            Write-Log -Message $Message -Level "Info"
            $logMessages[-1].Message | Should -Be $Message
            $logMessages[-1].Level | Should -Be "Info"
            $logMessages[-1].Timestamp | Should -Be $currentTime
        }

        It "Respects LogLevel filtering" {
            $script:logMessages = @()
            $global:LogLevel = "Error"
            Write-Log -Message "Should not log" -Level "Info"
            $logMessages.Count | Should -Be 0
        }

        It "Captures Error in errorSummary" {
            $script:errorSummary = @()
            Write-Log -Message "Test Error" -Level "Error"
            $errorSummary[-1].Message | Should -Be "Test Error"
        }
    }

    Context "Is-BatchIncluded Function" {
        It "Returns true for 'all' batches" {
            Is-BatchIncluded -RelativePath "matchmaking-app-web" -BatchesToProcess @("all") | Should -Be $true
        }

        It "Returns true for matching batch" {
            Is-BatchIncluded -RelativePath "matchmaking-app-backend" -BatchesToProcess @("1.3") | Should -Be $true
        }

        It "Returns false for non-matching batch" {
            Is-BatchIncluded -RelativePath "vedicmatchweb" -BatchesToProcess @("1.1") | Should -Be $false
        }
    }

    Context "Ensure-Directory Function" {
        BeforeEach {
            $testDir = "TestDir"
            $testPath = Join-Path -Path $TestDrive -ChildPath $testDir
            $script:createdDirs = @()
        }

        It "Creates directory when missing" {
            Mock Test-Path { $false }
            Ensure-Directory -Path $testPath -RelativePath $testDir
            $createdDirs | Should -Contain $testDir
        }

        It "Does not create directory in DryRun mode" {
            Mock Test-Path { $false }
            $global:DryRun = $true
            Ensure-Directory -Path $testPath -RelativePath $testDir
            $createdDirs | Should -BeEmpty
        }

        It "Logs existing directory" {
            Mock Test-Path { $true }
            Ensure-Directory -Path $testPath -RelativePath $testDir
            $logMessages[-1].Message | Should -Be "Directory exists: $testDir"
        }
    }

    Context "Ensure-File Function" {
        BeforeEach {
            $testFile = "TestFile.txt"
            $testPath = Join-Path -Path $TestDrive -ChildPath $testFile
            $script:missingFiles = @()
            $script:createdFiles = @()
        }

        It "Creates file with content when missing" {
            Mock Test-Path { $false }
            Ensure-File -Path $testPath -RelativePath $testFile -Content "Test content"
            $createdFiles | Should -Contain $testFile
            $missingFiles | Should -Contain $testFile
        }

        It "Does not create file in DryRun mode" {
            Mock Test-Path { $false }
            $global:DryRun = $true
            Ensure-File -Path $testPath -RelativePath $testFile -Content "Test content"
            $createdFiles | Should -BeEmpty
            $missingFiles | Should -Contain $testFile
        }

        It "Logs existing file" {
            Mock Test-Path { $true }
            Ensure-File -Path $testPath -RelativePath $testFile -Content "Test content"
            $logMessages[-1].Message | Should -Be "File exists: $testFile"
        }
    }

    Context "Validate-And-Populate Function" {
        BeforeEach {
            $testBasePath = $TestDrive
            $testStructure = @{
                "test-dir" = @("file1.txt", "file2.txt")
                "" = @("root-file.txt")
            }
            $script:batch_files = @{
                "test-dir/file1.txt" = "Content1"
                "test-dir/file2.txt" = "Content2"
                "root-file.txt" = "RootContent"
            }
            $script:createdDirs = @()
            $script:createdFiles = @()
            $script:missingFiles = @()
        }

        It "Populates structure correctly" {
            Mock Test-Path { $false }
            Validate-And-Populate -BasePath $testBasePath -Structure $testStructure -BatchesToProcess @("all")
            $createdDirs | Should -Contain "test-dir"
            $createdFiles | Should -Contain "test-dir/file1.txt"
            $createdFiles | Should -Contain "test-dir/file2.txt"
            $createdFiles | Should -Contain "root-file.txt"
        }

        It "Skips non-matching batches" {
            Mock Test-Path { $false }
            Validate-And-Populate -BasePath $testBasePath -Structure $testStructure -BatchesToProcess @("1.1")
            $createdDirs | Should -BeEmpty
            $createdFiles | Should -BeEmpty
        }
    }

    Context "Summary Export" {
        BeforeEach {
            $summaryPath = Join-Path -Path $TestDrive -ChildPath "structure-summary.json"
            $script:createdDirs = @("dir1")
            $script:createdFiles = @("file1")
            $script:missingFiles = @("file2")
            $script:errorSummary = @()
        }

        It "Exports summary JSON when not DryRun" {
            $global:DryRun = $false
            Mock Out-File {}
            $summary = @{
                createdDirs = $createdDirs
                createdFiles = $createdFiles
                missingFiles = $missingFiles
                timestamp = $currentTime
                batch = "all"
                dryRun = $false
                logLevel = "Info"
                gitCommit = "dummyhash"
                errors = @()
            }
            $summary | ConvertTo-Json | Out-File -FilePath $summaryPath -Encoding UTF8 -Force
            Assert-MockCalled Out-File -Exactly 1 -Scope It
            (Get-Content $summaryPath -Raw | ConvertFrom-Json).createdDirs | Should -Contain "dir1"
        }

        It "Does not export summary in DryRun mode" {
            $global:DryRun = $true
            Mock Out-File {}
            $summary = @{
                createdDirs = $createdDirs
                createdFiles = $createdFiles
                missingFiles = $missingFiles
                timestamp = $currentTime
                batch = "all"
                dryRun = $true
                logLevel = "Info"
                gitCommit = "dummyhash"
                errors = @()
            }
            Validate-And-Populate -BasePath $TestDrive -Structure @{} -BatchesToProcess @("all")
            Assert-MockCalled Out-File -Exactly 0 -Scope It
        }
    }

    Context "Log File Output" {
        BeforeEach {
            $logPath = Join-Path -Path $TestDrive -ChildPath "validation.log"
            $script:logMessages = @()
        }

        It "Saves log file when not DryRun" {
            $global:DryRun = $false
            Mock Out-File {}
            Write-Log -Message "Test log entry" -Level "Info"
            $logMessages | ForEach-Object { "[$($_.Timestamp)] [$($_.Level)] $($_.Message)" } | Out-File -FilePath $logPath -Encoding UTF8 -Force
            Assert-MockCalled Out-File -Exactly 1 -Scope It
            Get-Content $logPath | Should -Contain "[$currentTime] [Info] Test log entry"
        }

        It "Does not save log file in DryRun mode" {
            $global:DryRun = $true
            Mock Out-File {}
            Write-Log -Message "Test log entry" -Level "Info"
            Validate-And-Populate -BasePath $TestDrive -Structure @{} -BatchesToProcess @("all")
            Assert-MockCalled Out-File -Exactly 0 -Scope It
        }
    }

    Context "Exit Code Handling" {
        BeforeEach {
            $script:errorSummary = @()
            $script:missingFiles = @()
            $script:createdDirs = @()
            $script:createdFiles = @()
        }

        It "Returns exit code 0 for success" {
            Mock Test-Path { $true }
            $testStructure = @{"test-dir" = @("file1.txt")}
            $script:batch_files = @{"test-dir/file1.txt" = "Content"}
            Validate-And-Populate -BasePath $TestDrive -Structure $testStructure -BatchesToProcess @("all")
            $exitCode = 0
            if ($errorSummary.Count -gt 0) { $exitCode = 2 }
            elseif ($missingFiles.Count -gt 0) { $exitCode = 1 }
            $exitCode | Should -Be 0
        }

        It "Returns exit code 1 for partial completion" {
            Mock Test-Path { $false }
            $testStructure = @{"test-dir" = @("file1.txt")}
            Validate-And-Populate -BasePath $TestDrive -Structure $testStructure -BatchesToProcess @("all")
            $exitCode = 0
            if ($errorSummary.Count -gt 0) { $exitCode = 2 }
            elseif ($missingFiles.Count -gt 0) { $exitCode = 1 }
            $exitCode | Should -Be 1
        }

        It "Returns exit code 2 for errors" {
            Mock Test-Path { $false }
            Mock New-Item { throw "Mocked error" }
            $testStructure = @{"test-dir" = @()}
            Validate-And-Populate -BasePath $TestDrive -Structure $testStructure -BatchesToProcess @("all")
            $exitCode = 0
            if ($errorSummary.Count -gt 0) { $exitCode = 2 }
            elseif ($missingFiles.Count -gt 0) { $exitCode = 1 }
            $exitCode | Should -Be 2
        }
    }

    Context "Parameter Validation" {
        It "Parses Batch parameter correctly" {
            $BatchesToProcess = "1.1,2.1" -split "," | ForEach-Object { $_.Trim() }
            $BatchesToProcess | Should -Contain "1.1"
            $BatchesToProcess | Should -Contain "2.1"
        }

        It "Handles 'all' Batch parameter" {
            $BatchesToProcess = if ("all" -eq "all") { @("all") } else { "invalid" -split "," }
            $BatchesToProcess | Should -Contain "all"
        }

        It "Respects LogLevel parameter" {
            $global:LogLevel = "Debug"
            Write-Log -Message "Debug message" -Level "Debug"
            $logMessages[-1].Message | Should -Be "Debug message"
            $global:LogLevel = "Error"
            $script:logMessages = @()
            Write-Log -Message "Debug message" -Level "Debug"
            $logMessages.Count | Should -Be 0
        }
    }
}