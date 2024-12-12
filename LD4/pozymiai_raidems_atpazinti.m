function pozymiai = pozymiai_raidems_atpazinti(pavadinimas, pvz_eiluciu_sk)
%%  pozymiai = pozymiai_raidems_atpazinti(pavadinimas, pvz_eiluciu_sk)
% Features = pozymiai_raidems_atpazinti(image_file_name, Number_of_symbols_lines)
% taikymo pavyzdys:
% pozymiai = pozymiai_raidems_atpazinti('test_data.png', 8); 
% example of function use:
% Feaures = pozymiai_raidems_atpazinti('test_data.png', 8);
%%
% Vaizdo su pavyzdziais nuskaitymas | Read image with written symbols
V = imread(pavadinimas);
figure(12), imshow(V)
%% Raidziu iskirpimas ir sudeliojimas i kintamojo 'objektai' celes |
%% Perform segmentation of the symbols and write into cell variable 
% RGB image is converted to grayscale
V_pustonis = rgb2gray(V); %%pustoninis viazdas
% vaizdo keitimo dvejetainiu slenkstines reiksmes paieska
% a threshold value is calculated for binary image conversion
slenkstis = graythresh(V_pustonis); %%nustato optimalu slenksti vaizdo dvejetaiinimui
% pustonio vaizdo keitimas dvejetainiu
% a grayscale image is converte to binary image
V_dvejetainis = im2bw(V_pustonis,slenkstis);  %%suskirsto vaizdą į juoda-balta (dvejetainį) pagal nustatytą slenkstį. Rezultatas: juodai baltas vaizdas, kuriame simboliai turėtų būti atskirti nuo fono.
% rezultato atvaizdavimas
% show the resulting image
figure(1), imshow(V_dvejetainis)
% vaizde esanciu objektu kontûru paieðka
% search for the contour of each object
V_konturais = edge(uint8(V_dvejetainis)); %%iesko konturu isryskina konturis
% rezultato atvaizdavimas
% show the resulting image
figure(2),imshow(V_konturais)
% objektų konturu uzpildymas 
% fill the contours
se = strel('square',7); % strukturinis elementas uzpildymui
V_uzpildyti = imdilate(V_konturais, se);  %%isplecia padidina konturus spragu uzpildymui
% rezultato atvaizdavimas
% show the result
figure(3),imshow(V_uzpildyti)
% tustumu objetu viduje uzpildymas
% fill the holes
V_vientisi= imfill(V_uzpildyti,'holes'); %%uzpildo skyles objektuose kad butu vientisi
% rezultato atvaizdavimas
% show the result
figure(4),imshow(V_vientisi)
% vientisu objektu dvejetainiame vaizde numeravimas. Objektu zymejimas ir
% pozymiu skaiciavimas
% set labels to binary image objects
[O_suzymeti Skaicius] = bwlabel(V_vientisi); %% sunumeruoja kiekvieną atskirą objektą dvejetainiame vaizde. Skaicius – objektų skaičius.
% apskaiciuojami objektu dvejetainiame vaizde pozymiai
% calculate features for each symbol
O_pozymiai = regionprops(O_suzymeti); %% iš kiekvieno objekto išskaičiuoja požymius, pvz., BoundingBox (ribojantį stačiakampi(
% nuskaitomos pozymiu - objektu ribu koordinaciu - reiksmës
% find/read the bounding box of the symbol
%Čia iš O_pozymiai ištraukiamos objektų ribos ir centroidų koordinates. Koordinatės pergrupuojamos, kad būtų patogu tvarkyti.
O_ribos = [O_pozymiai.BoundingBox];
% kadangi ribà nusako 4 koordinatës, pergrupuojame reiksmes
% change the sequence of values, describing the bounding box
O_ribos = reshape(O_ribos,[4 Skaicius]); % Skaicius - objektø skaièius
% nuskaitomos pozymiu - objektu masës centro koordinačiu - reiksmës
% reag the mass center coordinate
O_centras = [O_pozymiai.Centroid];  %% Objektai išrikiuojami pagal vertikalią ašį (kad sutvarkytume juos eilėmis).
% kadangi centra nusako 2 koordinatës, pergrupuojame reiksmes
% group center coordinate values
O_centras = reshape(O_centras,[2 Skaicius]);
O_centras = O_centras';
% pridedamas kiekvienam objektui vaize numeris (trecias stulpelis salia koordinaciu)
% set the label/number for each object in the image
O_centras(:,3) = 1:Skaicius;
% surusiuojami objektai pagal x koordinate - stulpeliái
% arrange objects according to the column number
O_centras = sortrows(O_centras,2);
% rûsiojama atsizvelgiant i pavyzdziu eilučių ir raidžiu skaiciu
% sort accordign to the number of rows and number of symbols in the row
raidziu_sk = Skaicius/pvz_eiluciu_sk; % Čia darome prielaidą, kad bendras objektų skaičius Skaicius tolygiai pasiskirsto per pvz_eiluciu_sk eilutes. Kiekvienai eilutei atskirai surikiuojame objektus horizontaliai, kad gautume tvarkingą raidžių seką.
for k = 1:pvz_eiluciu_sk
    O_centras((k-1)*raidziu_sk+1:k*raidziu_sk,:) = ...
        sortrows(O_centras((k-1)*raidziu_sk+1:k*raidziu_sk,:),3);
end
% is dvejetainio vaizdo pagal objektį ribas iskerpami vaizdo fragmentai
% imcrop iškerpa kiekvieną simbolį pagal jo BoundingBox. Tada pavaizduojame visus iškirptus simbolius lentelėje (subplots).
% cut the symbol from initial image according to the bounding box estimated in binary image
for k = 1:Skaicius
    objektai{k} = imcrop(V_dvejetainis,O_ribos(:,O_centras(k,3)));
end
% vieno is vaizdo fragmentų atvaizdavimas
% show one of the symbol's image
figure(5),
for k = 1:Skaicius % Šiame žingsnyje pašalinamos tuščios baltos eilutės ir stulpeliai, kad aplink raidę neliktų fono.
   subplot(pvz_eiluciu_sk,raidziu_sk,k), imshow(objektai{k})
end
% vaizdo fragmentai apkerpami, panaikinant fona is krastu (pagal staciakampi)
% image segments are cutt off
% Čia 70x50 vaizdas padalinamas į 7 eilutes po 5 blokus (kiekvienas blokas 10x10), iš kiekvieno bloko suskaičiuojamas intensyvumas. Tada šie intensyvumo duomenys normalizuojami ir tampa simbolį apibūdinančiais požymiais (vektoriumi). pozymiai grąžinamas kaip celių masyvas, kuriame kiekviena ceelė atitinka vienos raidės požymių vektorių.
for k = 1:Skaicius % Skaicius = 88, jei yra 88 raidës
    V_fragmentas = objektai{k};
    % nustatomas kiekvieno vaizdo fragmento dydis
    % estimate the size of each segment
    [aukstis, plotis] = size(V_fragmentas);
    
    % 1. Baltu stulpeliu naikinimas
    % eliminate white spaces
    % apskaiciuokime kiekvieno stulpelio suma
    stulpeliu_sumos = sum(V_fragmentas,1);
    % naikiname tuos stulpelius, kur suma lygi auksciui
    V_fragmentas(:,stulpeliu_sumos == aukstis) = [];
    % perskaiciuojamas objekto dydis
    [aukstis, plotis] = size(V_fragmentas);
    % 2. Baltu eiluciu naikinimas
    % apskaiciuokime kiekvienos eilutës suma
    eiluciu_sumos = sum(V_fragmentas,2);
    % naikiname tas eilutes, kur suma lygi plociui
    V_fragmentas(eiluciu_sumos == plotis,:) = [];
    objektai{k}=V_fragmentas;% áraðome vietoje neapkarpyto
end
% vieno is vaizdo fragmentu atvaizdavimas
% show the segment
figure(6),
for k = 1:Skaicius
   subplot(pvz_eiluciu_sk,raidziu_sk,k), imshow(objektai{k})
end
%%
%% Suvienodiname vaizdo fragmentu dydzius iki 70x50
%% Make all segments of the same size 70x50
for k=1:Skaicius
    V_fragmentas=objektai{k};
    V_fragmentas_7050=imresize(V_fragmentas,[70,50]);
    % padalinkime vaizdo fragmenta i 10x10 dydzio dalis
    % divide each image into 10x10 size segments
    for m=1:7
        for n=1:5
            % apskaiciuokime kiekvienos dalies vidutini sviesuma 
            % calculate an average intensity for each 10x10 segment
            Vid_sviesumas_eilutese=sum(V_fragmentas_7050((m*10-9:m*10),(n*10-9:n*10)));
            Vid_sviesumas((m-1)*5+n)=sum(Vid_sviesumas_eilutese);
        end
    end
    % 10x10 dydzio dalyje maksimali sviesumo galima reiksmë yra 100
    % normuokime sviesumo reiksmes intervale [0, 1]
    % perform normalization
    Vid_sviesumas = ((100-Vid_sviesumas)/100);
    % rezultatu (pozmius) neuronu tinklui patogiau pateikti stulpeliu
    % transform features into column-vector
    Vid_sviesumas = Vid_sviesumas(:);
    % issaugome apskaiciuotus pozymius i bendra kintamajį
    % save all fratures into single variable
    pozymiai{k} = Vid_sviesumas;
end