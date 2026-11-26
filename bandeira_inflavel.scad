// Bandeira inflável de duas pontas. Unidades em milímetros.
// F5: vistas e estampa ilustrativa. F6: geometria do conjunto, com câmara oca.
// Em "corte", abre-se uma janela apenas na face dianteira. Gire o modelo para
// ver os fios atravessando a espessura. "detalhe" aproxima a mesma janela.
// Em calmaria, a superfície média é plana por padrão. A queda de 185 mm
// aproxima o caso simulado a 8 kPa. A forma é ilustrativa e ajustável.

/* [Visualização] */
vista = "conjunto"; // [conjunto:Perspectiva, frente:Frente, verso:Verso, perfil:Perfil, corte:Corte da face dianteira, detalhe:Detalhe dos fios]
mostrar_estampa = true;
mostrar_fios = true;

/* [Geometria da bandeira em mm] */
comprimento = 1550; // [1000:10:2000]
altura = 740; // [500:10:1000]
recorte_v = 320; // [100:10:500]
espessura_camara = 46; // [20:2:80]
queda_da_ponta = 185; // [0:5:240]
ondulacao = 0; // [0:0.1:1.5]

/* [Hidden] */
$fn=32;
nx=44;
nz=24; // Par para que uma linha da malha acompanhe o vértice do recorte em V.
passo=nx+1;
camada=passo*(nz+1);
parede=1.2;
z_inferior=1220;
eixo_mastro=-83;
raio_mastro=17;
altura_base=70;
aberto=(vista=="corte" || vista=="detalhe");
i0=15; i1=32; j0=7; j1=18;
azul=[0.08,0.34,0.44];
metal=[0.58,0.65,0.65];
grafite=[0.15,0.19,0.21];
dourado=[0.87,0.57,0.24];
creme=[0.99,0.94,0.79];
verde=[0.14,0.55,0.56];

function largura_em(v)=comprimento-recorte_v*(1-abs(2*v-1));
function centro(x,v)=ondulacao*(160*sin(320.86*x/1000-14.32)
                    +40*sin(515.66*x/1000+57.3*v))*min(1,0.0024*x);
function altura_em(x,v)=z_inferior+altura*v
                  -queda_da_ponta*x/comprimento;
function meia_espessura(x,v)=
    let(d=max(0,min(x,largura_em(v)-x,altura*v,altura*(1-v))),
        t=min(1,d/37))
    parede+(espessura_camara/2)*pow(sin(90*t),0.68);
function ponto(x,v,lado,ajuste=0)=
    [x, centro(x,v)+lado*(meia_espessura(x,v)+ajuste), altura_em(x,v)];

// Quatro superfícies: frente e verso externos e respectivos lados internos.
// A cavidade termina uma célula antes do contorno, formando a faixa vedada.
function idx(i,j,k)=i+passo*j+camada*k;
function celula(i,j,k,inverter=false)=
    let(a=idx(i,j,k),b=idx(i+1,j,k),c=idx(i+1,j+1,k),d=idx(i,j+1,k))
    inverter ? [[a,c,b],[a,d,c]] : [[a,b,c],[a,c,d]];
function contorno(a,b,c,d)=concat(
    [for(i=[a:b-1]) idx(i,c,0)], [for(j=[c:d-1]) idx(b,j,0)],
    [for(i=[b:-1:a+1]) idx(i,d,0)], [for(j=[d:-1:c+1]) idx(a,j,0)]);
function unir_bordas(anel,k,l)=[for(t=[0:len(anel)-1])
    let(a=anel[t],b=anel[(t+1)%len(anel)],i=k*camada,j=l*camada)
    each [[a+i,b+i,b+j],[a+i,b+j,a+j]]];
function janela(i,j)=aberto && i>=i0 && i<i1 && j>=j0 && j<j1;
module envelope(){
    pontos=[for(k=[0:3],j=[0:nz],i=[0:nx])
        let(v=j/nz,x=i*largura_em(v)/nx)
        ponto(x,v,(k==0 || k==2)?-1:1,k>=2?-parede:0)];
    faces=concat(
        [for(j=[0:nz-1],i=[0:nx-1]) if(!janela(i,j)) each celula(i,j,0,true)],
        [for(j=[0:nz-1],i=[0:nx-1]) each celula(i,j,1)],
        [for(j=[1:nz-2],i=[1:nx-2]) if(!janela(i,j)) each celula(i,j,2)],
        [for(j=[1:nz-2],i=[1:nx-2]) each celula(i,j,3,true)],
        unir_bordas(contorno(0,nx,0,nz),0,1),
        unir_bordas(contorno(1,nx-1,1,nz-1),3,2),
        aberto?unir_bordas(contorno(i0,i1,j0,j1),2,0):[]);
    color(azul) polyhedron(pontos,faces,convexity=16);
}
module entre(a,b,r){
    d=b-a;
    translate(a) rotate([0,acos(d.z/norm(d)),atan2(d.y,d.x)])
        cylinder(h=norm(d),r=r,$fn=12);
}
module fios(){
    // Pontos da malha garantem a união de cada fio às duas peles.
    color(dourado) for(j=[2:3:nz-2],i=[2:3:nx-2]){
        v=j/nz; x=i*largura_em(v)/nx;
        // A ponta de um fio exposto marca a posição da pele retirada.
        entre(ponto(x,v,-1,-parede/2),ponto(x,v,1,-parede/2),1.8);
    }
}
module suporte(){
    color(grafite) translate([eixo_mastro-230,-210,0])
        cube([460,420,altura_base]);
    topo=z_inferior+altura+100;
    color(metal){
        translate([eixo_mastro,0,altura_base-1])
            cylinder(r=raio_mastro,h=topo-altura_base+1);
        translate([eixo_mastro,0,topo]) sphere(r=24);
    }
    for(v=[0.055,0.945]){
        z=altura_em(0,v);
        color(grafite) translate([eixo_mastro,0,z-18.5]) cylinder(h=37,r=22);
        // Alça de fita dobrada em volta do colar e presa à borda do tecido.
        color(verde) translate([0,0,z-16]) linear_extrude(32)
            difference(){
                hull(){
                    translate([eixo_mastro,0]) circle(r=24);
                    translate([12,0]) circle(r=5);
                }
                hull(){
                    translate([eixo_mastro,0]) circle(r=20);
                    translate([6,0]) circle(r=1.8);
                }
            }
    }
}
module valvula(){
    v=0.12; x=0.065*largura_em(v); p=ponto(x,v,-1);
    // Orientar a flange segundo a normal local da face impressa.
    dx=ponto(x+1,v,-1)-p; dv=ponto(x,v+0.001,-1)-p;
    n=cross(dx,dv)/norm(cross(dx,dv));
    translate(p) rotate([0,acos(n.z),atan2(n.y,n.x)]){
        color(dourado) translate([0,0,-4]) cylinder(h=9,r=20);
        color(grafite) translate([0,0,4]) cylinder(h=7,r=14);
    }
}

// Estampa de pré-visualização: pigmento gráfico, sem relevo na malha exportada.
// Faixas seguem a curvatura; o texto é dividido em tiras para acompanhar o pano.
function unitario(a)=a/norm(a);
module tinta_local(x,v,passo_x=1) {
    p=ponto(x,v,-1,2.8);
    a=(ponto(x+passo_x,v,-1,2.8)-p)/passo_x;
    b=unitario(ponto(x,v+0.001,-1,2.8)-p);
    n=unitario(cross(a,b));
    multmatrix([[a.x,b.x,n.x,p.x],[a.y,b.y,n.y,p.y],
                [a.z,b.z,n.z,p.z],[0,0,0,1]]) children();
}
module faixa(v0,v1,cor){
    n=56;
    pontos=[for(k=[0:1],v=[v0,v1],i=[0:n])
        let(x=12+(largura_em(v)-24)*i/n) ponto(x,v,-1,2.8+k*0.3)];
    a=n+1; b=2*a;
    faces=concat([for(i=[0:n-1]) each
        [[i,i+1,i+a+1],[i,i+a+1,i+a],[b+i,b+i+a+1,b+i+1],[b+i,b+i+a,b+i+a+1],
         [i,b+i,b+i+1,i+1],[a+i,a+i+1,b+a+i+1,b+a+i]]],
        [[0,a,b+a,b],[n,b+n,b+a+n,a+n]]);
    color(cor) polyhedron(pontos,faces,convexity=10);
}
module estampa(){
    faixa(.21,.255,creme);
    faixa(.12,.205,verde);
    color(creme) tinta_local(.13*comprimento,.61) linear_extrude(.3)
        polygon([for(k=[0:9]) let(r=(k%2==0?0.08:0.034)*altura) [r*sin(36*k),r*cos(36*k)]]);
    tam=min(0.135*altura,0.065*comprimento);
    fatia=tam/3;
    for(j=[0:21]){
        x0=j*fatia;
        color(creme) tinta_local(.245*comprimento+x0,.54,fatia)
            linear_extrude(.3)
            intersection(){
                translate([-x0,0]) text("Campanha",size=tam,font="Liberation Sans");
                translate([0,-tam]) square([fatia+0.01,3*tam]);
            }
    }
}
alvo=ponto(largura_em(.52)*.52,.52,0);
$vpr=vista=="frente"?[90,0,0]:vista=="verso"?[90,0,180]:
     vista=="perfil"?[90,0,90]:vista=="detalhe"?[68,0,335]:
     vista=="corte"?[79,0,345]:[75,0,348];
$vpt=vista=="detalhe"?alvo:[comprimento*.39,0,(z_inferior+altura+100)/2];
$vpd=vista=="detalhe"?1.4*comprimento:3.1*max(z_inferior+altura+100,comprimento);
assert(recorte_v>0 && recorte_v<comprimento && altura>0 && espessura_camara>0);
envelope();
if(mostrar_fios) fios();
suporte();
valvula();
if(mostrar_estampa && $preview && !aberto) estampa();
