# Caminho para salvar imagens
$diretorioImagens = "$env:APPDATA\Vampetaco\Imagens"
if (!(Test-Path $diretorioImagens)) {
    New-Item -ItemType Directory -Path $diretorioImagens | Out-Null
}

# Caminho onde o script será copiado
$diretorioVampetaco = "$env:APPDATA\Vampetaco"
if (!(Test-Path $diretorioVampetaco)) {
    New-Item -ItemType Directory -Path $diretorioVampetaco | Out-Null
}

# Caminho original e cópia do script
$scriptPathOriginal = $MyInvocation.MyCommand.Path
$scriptPathCopia = "$diretorioVampetaco\Vampetaco.ps1"

if (!(Test-Path $scriptPathCopia)) {
    Copy-Item -Path $scriptPathOriginal -Destination $scriptPathCopia
}

# Criar o VBS para executar o script sem abrir o PowerShell
$vbsPath = "$diretorioVampetaco\Vampetaco.vbs"
$vbsContent = @"
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
scriptDir = objFSO.GetParentFolderName(WScript.ScriptFullName)
scriptPath = scriptDir & "\Vampetaco.ps1"
objShell.Run "powershell.exe -ExecutionPolicy Bypass -File """ & scriptPath & """", 0, False
"@
$vbsContent | Out-File -Encoding ASCII $vbsPath

# Criar atalho para executar o VBS na inicialização
function Criar-AtalhoInicializacao {
    $startupFolder = [System.Environment]::GetFolderPath('Startup')
    $shortcutPath = Join-Path $startupFolder "Vampetaco.lnk"

    $wsh = New-Object -ComObject WScript.Shell
    $shortcut = $wsh.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "wscript.exe"
    $shortcut.Arguments = "`"$vbsPath`""
    $shortcut.Save()
}

Criar-AtalhoInicializacao

# Lista de URLs das imagens
$imagensURLs = @(
    "https://raw.githubusercontent.com/Gustavohps10/vampetaco/main/images/1-vampetaco-cease-fire.jpg",
    "https://raw.githubusercontent.com/Gustavohps10/vampetaco/main/images/2-vampetaco-abner.jpg",
    "https://raw.githubusercontent.com/Gustavohps10/vampetaco/main/images/3-vampetaco-yugioh.jpeg",
    "https://raw.githubusercontent.com/Gustavohps10/vampetaco/main/images/4-vampetaco-corte.jpg",
    "https://raw.githubusercontent.com/Gustavohps10/vampetaco/main/images/5-vampetaco-cristiano-ronaldo.jpg"
)

# Baixa imagens se ainda não existirem
$imagensURLs | ForEach-Object {
    $nomeArquivo = [System.IO.Path]::GetFileName($_)
    $caminhoImagem = "$diretorioImagens\$nomeArquivo"
    if (!(Test-Path $caminhoImagem)) {
        Invoke-WebRequest -Uri $_ -OutFile $caminhoImagem
    }
}

# Função para trocar o papel de parede
function Trocar-PapelDeParede {
    $imagens = Get-ChildItem -Path $diretorioImagens -Filter *.jpg
    if ($imagens.Count -gt 0) {
        $imagemEscolhida = $imagens[$global:imagemIndex]
        $caminhoImagem = $imagemEscolhida.FullName

        Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;
        public class Wallpaper {
            [DllImport("user32.dll", CharSet = CharSet.Auto)]
            public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
        }
"@
        [Wallpaper]::SystemParametersInfo(0x0014, 0, $caminhoImagem, 0x01)
        
        $global:imagemIndex++
        if ($global:imagemIndex -ge $imagens.Count) {
            $global:imagemIndex = 0
        }
    }
}

# Iniciar a troca automática do papel de parede
$global:imagemIndex = 0
while ($true) {
    Trocar-PapelDeParede
    Start-Sleep -Seconds 3
}
