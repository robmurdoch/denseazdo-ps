Describe "UtilityCmdlets" {
   BeforeAll {

      $cmdletToTest = (Split-Path -Leaf $PSCommandPath).Replace(".tests.", ".")

      . "$PSScriptRoot/../../src/public/$cmdletToTest"
   }

   Context "New-FileNameWithDate" {

      It 'appends current date to file name' {

         [string]$todaysDate = Get-Date -f yyyy-MM-dd
         [string]$baseNameInput = "C:\temp\myfile.csv"
         [string]$expected = "C:\temp\myfile $todaysDate.csv"
         
         (New-FileNameWithDate -BaseName $baseNameInput) | 
         Should -Be $expected
      }

      # It 'throws without file extension' {

      #    [string]$baseNameInput = "C:\temp\myfile"
         
      #    { New-FileNameWithDate -BaseName $baseNameInput } | Should -Throw
      # }

      # It 'throws without name' {

      #    [string]$baseNameInput = "c:\temp\.csv"
         
      #    { New-FileNameWithDate -BaseName $baseNameInput } | Should -Throw
      # }

      # It 'throws without path' {

      #    [string]$baseNameInput = ".csv"
         
      #    { New-FileNameWithDate -BaseName $baseNameInput } | Should -Throw
      # }
   }
}