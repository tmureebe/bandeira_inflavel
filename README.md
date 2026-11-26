# Bandeira inflável de duas pontas

Uma bandeira publicitária de **1,55 m × 0,74 m** com recorte em V e duas alças presas a um mastro lateral. Duas faces de tecido, vedadas pelo contorno, formam uma câmara de ar. Os fios internos limitam a separação entre as faces a cerca de **4,6 cm**. A pressão ajuda a sustentar as pontas em calmaria.

## Animação no Blender

Abra o arquivo no **Blender 5.3** e pressione **Espaço**. A câmara permanece a **8 kPa de pressão manométrica** durante os 10 segundos. A bandeira começa em calmaria. A partir de 2 segundos, entra vento transversal com rajadas ilustrativas de até cerca de **5 m/s**. O indicador na tela mostra a velocidade do vento.

A animação usa um modelo simplificado de flexão lateral, arrasto e amortecimento. As chaves de forma e a textura da estampa fictícia estão incorporadas ao arquivo. Selecione a cena **02 · Corte da câmara a 8 kPa** para ver os fios que ligam as duas faces. [Baixar o arquivo .blend](Bandeira%20infl%C3%A1vel.blend?raw=true)

## Modelo e documentação

- Abra a prévia com **F5** no OpenSCAD. Use os valores `corte` e `detalhe` do parâmetro `vista` para inspecionar o interior. [Modelo paramétrico em OpenSCAD](bandeira_inflavel.scad)
- Veja o conjunto, as duas fixações laterais e o funcionamento da câmara inflável. [Explicação ilustrada](Bandeira_inflavel_explicacao.pdf)
- Consulte a análise estática em calmaria, com as hipóteses do modelo e a comparação das formas de equilíbrio sob diferentes pressões. [Simulação em calmaria](Simulacao_bandeira_inflavel_em_calmaria.pdf)

## Licença

A documentação de hardware deste projeto é licenciada sob a **TAPR Noncommercial Hardware License 1.0**. [Texto integral em inglês](LICENSE.txt)
