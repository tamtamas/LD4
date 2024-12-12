close all
clear all
clc
%% raidziu pavyzdziu nuskaitymas ir pozymiu skaiciavimas
pavadinimas = 'train_data.png';
pozymiai_tinklo_mokymui = pozymiai_raidems_atpazinti(pavadinimas, 4);
%% Atpazintuvo kûrimas
% pozymiai is celiu masyvo perkeliami i matricà
P = cell2mat(pozymiai_tinklo_mokymui); % Paverčiami požymiai iš celių masyvo į matricą, kad būtų galima pateikti juos neuroniniam tinklui.
% sukuriama teisingu atsakymu matrica: 6 raidziu, 4 eilutes mokymui
T = [eye(6), eye(6), eye(6), eye(6)]; % KETURIOS EILUTES MOKYMUI
% sukuriamas SBF tinklas duotiems P ir T sarysiams
% create an RBF network for classification with 13 neurons, and sigma = 1
tinklas = newrb(P,T,0,1,5);
% Sukuriamas RBF neuroninis tinklas. Parametrai:
%Tikslumas (0 reiškia, kad siekiama minimalios klaidos).
%Sklaida (spread) = 1.
%Max neuronų sk. = 5
%% Tinklo patikra | Test of the network (recognizer)
% skaiciuojamas tinklo isëjimas nezinomiems pozymiams
P2 = P(:,19:24);
Y2 = sim(tinklas, P2);
% ieskoma, kuriame isejime gauta didziausia reiksmë
[a2, b2] = max(Y2);
%P2 paimame stulpelius (12:21), tai tam tikra požymių poaibė, kurių tinklas nematė mokymo metu (arba tiesiog testuojame su mokymo aibės dalimi). sim paleidžia tinklą su šiais požymiais. max suranda didžiausią išėjimo neuronų reikšmę – taip sužinome, kuri klasė atpažinta.
%% Rezultato atvaizdavimas
%% Visualize result
% apskaiciuosime raidziu skaiciu - pozymiu P2 stulpeliu skaiciu
raidziu_sk = size(P2,2);
% rezultatà saugosime kintamajame 'atsakymas'
atsakymas = [];
for k = 1:raidziu_sk
    switch b2(k)
        case 1
            atsakymas = [atsakymas, 'A'];
        case 2
            atsakymas = [atsakymas, 'T'];
        case 3
            atsakymas = [atsakymas, 'V'];
        case 4
            atsakymas = [atsakymas, 'S'];
        case 5
            atsakymas = [atsakymas, 'I'];
        case 6  
            atsakymas = [atsakymas, 'E'];
    end
end
% Pagal tai, kuris neuronų tinklo išėjimas aktyviausias, priskiriama raidė. Galiausiai išvedamas atpažintų raidžių žodis.
% pateikime rezultata komandiniame lange
% show the result in command window
disp(atsakymas)
% % figure(7), text(0.1,0.5,atsakymas,'FontSize',38)
%% zodzio "KADA" pozymiu isskyrimas 
%% Extract features of the test image
pavadinimas = 'test_data.png';
pozymiai_patikrai = pozymiai_raidems_atpazinti(pavadinimas, 1);
% Dabar atpažįstame raidę(-es) iš naujo paveikslėlio test_data.png, kuriame yra 1 eilutė raidžių.

%% Raidziu atpazinimas
% pozymiai is celiu masyvo perkeliami i matricà
% features from cell-variable are stored to matrix-variable
P2 = cell2mat(pozymiai_patikrai);
% skaiciuojamas tinklo isëjimas nezinomiems pozymiams
Y2 = sim(tinklas, P2);
% ieskoma, kuriame isëjime gauta didziausia reiksmë
[a2, b2] = max(Y2);
%% Rezultato atvaizdavimas | Visualization of result
% apskaiciuosime raidziu skaiciu - pozymiu P2 stulpeliu skaiciu
raidziu_sk = size(P2,2);
% rezultatà saugosime kintamajame 'atsakymas'
atsakymas = [];
for k = 1:raidziu_sk
    switch b2(k)
        case 1
            atsakymas = [atsakymas, 'A'];
        case 2
            atsakymas = [atsakymas, 'T'];
        case 3
            atsakymas = [atsakymas, 'V'];
        case 4
            atsakymas = [atsakymas, 'S'];
        case 5
            atsakymas = [atsakymas, 'I'];
        case 6  
            atsakymas = [atsakymas, 'E'];
    end
end
% pateikime rezultatà komandiniame lange
% disp(atsakymas)
figure(8), text(0.1,0.5,atsakymas,'FontSize',38), axis off
