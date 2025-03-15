# Caminho para salvar imagens
$diretorio = "$env:APPDATA\Vampetaco\Imagens"
if (!(Test-Path $diretorio)) {
    New-Item -ItemType Directory -Path $diretorio | Out-Null
}

# Lista de URLs das imagens
$imagensURLs = @(
    "https://conteudo.imguol.com.br/c/tab/b3/2023/03/27/vampeta-posa-em-sessao-de-fotos-para-a-revista-g-magazine-em-1999-1679953317299_v2_4x3.jpg"
    # "https://exemplo.com/imagem2.jpg"
    # "https://exemplo.com/imagem3.jpg"
)

# Baixa imagens se ainda não existirem
$imagensURLs | ForEach-Object {
    $nomeArquivo = [System.IO.Path]::GetFileName($_)
    $caminhoImagem = "$diretorio\$nomeArquivo"

    if (!(Test-Path $caminhoImagem)) {
        Invoke-WebRequest -Uri $_ -OutFile $caminhoImagem
    }
}

function Trocar-PapelDeParede {
    $imagens = Get-ChildItem -Path $diretorio -Filter *.jpg
    if ($imagens.Count -gt 0) {
        $imagemEscolhida = $imagens | Get-Random
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
    }
}

while ($true) {
    Trocar-PapelDeParede
    Start-Sleep -Seconds 10
}
