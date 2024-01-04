%% DE INTREBAT:
%1. Ce se ploteaza: abs(fft) sau abs(fft)^2?

%2. Cand calculam cât la sută din coeficienti compun pragurile alea de
%energie, procentul e din ce, din toți coeficienții FFT, sau doar din cei
%ai primei jumătăți?

%3. Să scalăm FFT-ul cu Fs sau Nr_esantioane? sau deloc?

%4. Cum plotam procentele de energie in 2D?

%6. Cum sa plotez componentele TKL-ului? Valoriile proprii? Nu pot sa le
%ordonez pe toate pentru ca n-am destula memorie. Dar in 2D?

%7. La fel la Haar? Ce componente plotez?

classdef    functii 
    methods     ( Static = true )

        function plot_gray(imagine_fft)
            [m,n] = size(imagine_fft);
            A = db(abs(imagine_fft));
            colormap jet
            imagesc(A)

            ox = (0:n-1) ./ n;
            oy = (0:m-1) ./ m;
            
            figure;
            [X, Y] = meshgrid(ox, oy);
            colormap jet
            h = surf(X, Y, A, 'FaceColor','interp');
            set(h,'LineStyle','none')
            set(gca,'Xdir','reverse','Ydir','reverse')
        end

        function plot_rgb(imagine_fft)
            [m,n,~] = size(imagine_fft);

            R = db(abs(imagine_fft(:, :, 1)));
            G = db(abs(imagine_fft(:, :, 2)));
            B = db(abs(imagine_fft(:, :, 3)));
                
            figure
            colormap jet
            subplot(3, 1, 1)
            imagesc(R)
            subplot(3, 1, 2)
            imagesc(G)
            subplot(3, 1, 3)
            imagesc(B)

            ox = (0:n-1) ./ n;
            oy = (0:m-1) ./ m;

            figure
            subplot(3, 1, 1)
            [X, Y] = meshgrid(ox, oy);
            colormap jet
            h = surf(X, Y, R, 'FaceColor','interp');
            set(h,'LineStyle','none')
            set(gca,'Xdir','reverse','Ydir','reverse')

            subplot(3, 1, 2)
            [X, Y] = meshgrid(ox, oy);
            colormap jet
            h = surf(X, Y, G, 'FaceColor','interp');
            set(h,'LineStyle','none')
            set(gca,'Xdir','reverse','Ydir','reverse')

            subplot(3, 1, 3)
            [X, Y] = meshgrid(ox, oy);
            colormap jet
            h = surf(X, Y, B, 'FaceColor','interp');
            set(h,'LineStyle','none')
            set(gca,'Xdir','reverse','Ydir','reverse')    
        end

        function [f, P1] = plot_1d(audio_fft, Fs, oy)
            if strcmp(oy, 'abs')
                P2 = abs(audio_fft);
                P1 = P2(1:length(audio_fft)/2+1);
                P1(2:end-1) = 2*P1(2:end-1);
            elseif strcmp(oy, 'power')
                P2 = audio_fft(1:length(audio_fft)/2+1);
                P1 = abs(P2).^2;
                P1(2:end-1) = 2*P1(2:end-1);
                P1 = db(P1);
            end

            f = Fs/length(audio_fft)*(0:(length(audio_fft)/2));
            f = f / Fs;

            figure
            plot(f, P1);
            title("Complex Magnitude of fft Spectrum")
            xlabel("Frecventa normalizata")
            if strcmp(oy, 'abs')
                ylabel("|fft(X)|")
            elseif strcmp(oy, 'power')
                ylabel("Spectral Power [dB]")
            end
        end

        function plot_1d_segmente(bucatiTransf, Transf)
            ox = (0:size(bucatiTransf, 2)-1);
            oy = (0:size(bucatiTransf{1},1)-1);
            
            if(strcmp(Transf, 'Haar2D') ~= 1)
                ox = (0:size(bucatiTransf, 2)-2);
                bucatiTransf = bucatiTransf(1 : end-1);
            end

            bucatiTransf = cell2mat(bucatiTransf);
            bucatiTransf = abs(bucatiTransf);
            
            figure
            [X, Y] = meshgrid(oy, ox);
            colormap jet
            h = surf(X, Y, bucatiTransf', 'FaceColor','interp');
            colorbar
            title("Magnitude of " + Transf + " Spectrum")
            
            if(strcmp(Transf,'Haar2D') == 1)
                xlabel('Index Linie')
                ylabel('Index Coloana')
            else
                xlabel("Index coeficienti " + Transf)
                ylabel("Index Segment")
            end
            zlabel("Magnitudine coeficient " + Transf)
            set(h,'LineStyle','none')
            set(gca,'Xdir','reverse','Ydir','reverse')
        end

        function norma_eroare = plot_eroare_1d(orig, rec, Fs)
            er = abs(orig - rec);
            T = 1 / Fs;

            norma_eroare = norm(orig-rec);
            
            figure
            t = (0:length(orig)-1)*T;
            plot(t,er)
            xlabel("t (seconds)")
            ylabel("y(t)")
            gtext(['Norma erorii: ' num2str(norma_eroare)]);

        end

        function plot_eroare_2d(orig, rec)
            ox = (0:size(orig, 1)-1);
            oy = (0:size(orig, 2)-1);
            if(size(orig, 3) ~= 3)
                 er = imabsdiff(orig, rec);

                 figure
                 [X, Y] = meshgrid(ox, oy);
                 colormap jet
                 h = surf(X, Y, er, 'FaceColor','interp');
                 set(h,'LineStyle','none')
                 xlabel('Index Linie')
                 ylabel('Index Coloana')
                 set(gca,'Xdir','reverse','Ydir','reverse')
                 text(119,0, 0.5, ['Norma erorii: ' num2str(sum(er, 'all'))], 'Rotation',+15);
                 colorbar;
            else
                er1 = imabsdiff(orig(:, :, 1), rec(:, :, 1));
                er2 = imabsdiff(orig(:, :, 2), rec(:, :, 2));
                er3 = imabsdiff(orig(:, :, 3), rec(:, :, 3));
                
                figure

                subplot(3, 1, 1)
                [X, Y] = meshgrid(ox, oy);
                colormap jet
                h = surf(X, Y, er1, 'FaceColor','interp');
                set(h,'LineStyle','none')
                xlabel('Index Linie')
                ylabel('Index Coloana')
                set(gca,'Xdir','reverse','Ydir','reverse')
                text(119,0, 0.5, ['Norma erorii: ' num2str(sum(er1, 'all'))], 'Rotation',+15);
                colorbar;

                subplot(3, 1, 2)
                [X, Y] = meshgrid(ox, oy);
                colormap jet
                h = surf(X, Y, er2, 'FaceColor','interp');
                set(h,'LineStyle','none')
                xlabel('Index Linie')
                ylabel('Index Coloana')
                set(gca,'Xdir','reverse','Ydir','reverse')
                text(119,0, 0.5, ['Norma erorii: ' num2str(sum(er2, 'all'))], 'Rotation',+15);
                colorbar;

                subplot(3, 1, 3)
                [X, Y] = meshgrid(ox, oy);
                colormap jet
                h = surf(X, Y, er3, 'FaceColor','interp');
                set(h,'LineStyle','none')
                xlabel('Index Linie')
                ylabel('Index Coloana')
                set(gca,'Xdir','reverse','Ydir','reverse')
                text(119,0, 0.5, ['Norma erorii: ' num2str(sum(er3, 'all'))], 'Rotation',+15);
                colorbar;
            end
        end

        function [fftizat_jum, energie, procente_coef] = proc_energie(fftizat, Fs)
            fftizat_jum = fftizat;
            fftizat_jum = fftizat_jum(1:length(fftizat)/2+1);
            fftizat_jum(2:end-1) = 2*fftizat_jum(2:end-1);

            energie = abs(fftizat_jum).^2;
       %     energie_totala = sum(energie) * (Fs/length(fftizat_jum));
            energie_totala = sum(energie);

            procente = [0.45, 0.50, 0.55, 0.60, 0.65, 0.70, 0.75, 0.80, 0.85, 0.90, 0.95, 0.99];
            indici = zeros(12, 1);

            suma = 0;
            j = 0;
            
            [f, ~] = functii.plot_1d(fftizat, Fs, 'power');

            for i = 1 : length(procente)
                while (suma <= procente(i) * energie_totala) & j < length(fftizat_jum)
                    j = j + 1;
                    suma = suma + energie(j);
                end
                indici(i) = j-1;
            end

            procente_coef = zeros(length(indici), 1);
            
            for i = 1 : length(indici)
                procente_coef(i) = indici(i)/length(fftizat_jum);
                xline(f(indici(i)), 'r--', [num2str(procente(i)*100) '% - Procent coef.: ' num2str(procente_coef(i))], 'LineWidth', 1);
            end
        end

        function [cumulative_energy, procente_coef] = proc_energie_klt(D)
            % Normalize eigenvalues to get proportion of variance
            proportion_variance = D / sum(D);
            
            % Compute cumulative variance
            cumulative_energy = cumsum(proportion_variance);
        
            % Define percentage thresholds
            procente = [0.45, 0.50, 0.55, 0.60, 0.65, 0.70, 0.75, 0.80, 0.85, 0.90, 0.95, 0.99];
            
            % Find number of components for each threshold
            procente_coef = arrayfun(@(x) find(cumulative_energy >= x, 1, 'first'), procente);
            % [D, ~] = sort(diag(D), "descend");
            % Plotting
            figure;
            plot(cumulative_energy);
            xlabel('Number of Components');
            ylabel('Cumulative Variance Explained');
            title('Scree Plot');
            grid on;
            hold on;
            for i = 1:length(procente)
                xline(procente_coef(i), 'r--', [' ' num2str(procente(i)*100) '%'], 'LineWidth', 1);
            end
            hold off;
        end

        function [bucati, rest] = segmentare_bucati(audio, len_bucati)
            bucati = [];
            rest = [];

            if size(audio, 1) > len_bucati
                for i = 1 : size(audio, 1) / len_bucati
                    bucati{i} = audio((i-1)*len_bucati+1:i*len_bucati);
                end
                rest = audio(i*len_bucati+1:end);
            end
        end

        function    [audio, audio_fft, Fs] = fft1d(x)
            [audio, Fs] = audioread(x);
            audio_fft = fft(audio);

            T = 1 / Fs;

            figure
            t = (0:length(audio)-1)*T;
            plot(t,audio)
            xlabel("t (seconds)")
            ylabel("y(t)")
            
            functii.plot_1d(audio_fft, Fs, 'abs');
        end

        function y = inv_fft1d(x, Fs)
            y = ifft(x);
            T = 1 / Fs;
            
            figure
            t = (0:length(y)-1)*T;
            plot(t,y)
            xlabel("t (seconds)")
            ylabel("y(t)")
        end

        function [imagine, imagine_fft] = fft2d(image)
            imagine = imread(image);
            [~, ~, ch] = size(imagine);
            
            imagine_fft=fft2(double(imagine));

            if(ch == 3)
                functii.plot_rgb(imagine_fft);
            else
                functii.plot_gray(imagine_fft);
            end
        end

        function y = inv_fft2d(x)
            y = uint8(ifft2(x));
            y = real(y);
            
            figure
            imagesc(abs(y))
            
            if(size(y, 3) ~= 3)
                colormap('gray')
            end
        end

        function [y, D, Vm, xM] = proc_tkl1d(x)
            xM = mean(x);
            x_centr = x - xM;
            [p_x, ~] = xcorr(x_centr, 'biased');
            % p_x = p_x / p_x(lags == 0); % Normalize by the value at lag 0
            
            R = fftshift(p_x); % in mod interesant, norma intre original si reconstruit da mai mica 
                               % daca fac fftshift
            R = toeplitz(R(1 : (size(p_x) + 1) / 2));
            [V, D] = eig(R);

            [D, indx] = sort(diag(D), "descend");
            V = V(:, indx);

            Vm = V;
            y = Vm'*x_centr;
        end


        function [audio, y, D, Vm, xM, Fs] = tkl1d(x)
            [audio, Fs] = audioread(x);

   %         bucati = [];
   %         rest = [];

   %         if size(audio, 1) > 1000
   %             for i = 1 : size(audio, 1) / 1000
   %                 bucati{i} = audio((i-1)*1000+1:i*1000);
   %             end
   %             rest = audio(i*1000+1:end);
   %         end
            [bucati, rest] = functii.segmentare_bucati(audio, 1000);


            if(~isempty(bucati))
                for i = 1 : size(bucati, 2)
                    [y{i}, D{i}, Vm{i}, xM{i}] = functii.proc_tkl1d(bucati{i}); 
                end
                if(~isempty(rest))
                    [y{i+1}, D{i+1}, Vm{i+1}, xM{i+1}] = functii.proc_tkl1d(rest);
                end
            else
                [y, D, Vm, xM] = functii.proc_tkl1d(audio);
            end

            functii.plot_1d_segmente(y, "TKL")
            
        end

        function [imagine, y, Vm, xM, xdim, ydim] = tkl2d(image)
            imagine = imread(image);
            imagine = double(imagine);
            [xdim, ydim, ch] = size(imagine);
            % ImgVector = Img(:);
            % % Or:
            imgVec = reshape(imagine, 1, []);
            % size(imgVec)
            [bucati, rest] = functii.segmentare_bucati(imgVec', 1000);
            % size(bucati)
            if(~isempty(bucati))
                for i = 1 : size(bucati, 2)
                    [y{i}, D{i}, Vm{i}, xM{i}] = functii.proc_tkl1d(bucati{i}); 
                end
                if(~isempty(rest))
                    [y{i+1}, D{i+1}, Vm{i+1}, xM{i+1}] = functii.proc_tkl1d(rest);
                end
            end
            % y = cat(1, y{:});
            % img = reshape(y, xdim, ydim);
            % functii.plot_gray(img)
        end

        function y = inv_tkl1d(x, Vm, xM)
            for i = 1 :size(x, 2)
                y{i} = Vm{i} * x{i} + xM{i};
            end

            y = cat(1, y{:});
           % T = 1/Fs;

           % figure
           % t = (0:length(y)-1)*T;
           % plot(t,y)
           % xlabel("t (seconds)")
           % ylabel("y(t)")
        end

        function y = inv_tkl2d(x, Vm, xM, xdim, ydim)
            imgVec = functii.inv_tkl1d(x, Vm, xM);
            y = reshape(imgVec, xdim, ydim);
        end

        function [y, huri, r] = proc_haar1d(x)
            L = log2(size(x));

            h = [1 1];
            g = [-1 1];

            for i = 1 : L
                huri{i} = conv(x, g);
                huri{i} = huri{i}(2:2:end);

                r = conv(x, h);
                r = r(2:2:end);
                x = r;
            end

            huriT = cell2mat(huri');
            huriT = flip(huriT);
            y = [r; huriT];
           
        end

        function [audio, y, huri, r, Fs] = haar1d(x, lungSegment)
            [audio, Fs] = audioread(x);

            [bucati, rest] = functii.segmentare_bucati(audio, lungSegment);


            if(~isempty(bucati))
                for i = 1 : size(bucati, 2)
                    [y{i}, huri{i}, r{i}] = functii.proc_haar1d(bucati{i}); 
                end
                if(~isempty(rest))
                    [y{i}, huri{i+1}, r{i+1}] = functii.proc_haar1d(rest);
                end
            end

            functii.plot_1d_segmente(y, "Haar")
        end

        function y = interpolare(x) 
            y = upsample(x, 2);
            y = y(1:size(y) - 1);
        end

        function x_intarziat = inv_haar1d(huri, r)
            h = [1 1] / 2;
            g = [1 -1] / 2;

            for i = 1 :size(r, 2)
                rCurent = r{i};
                for j = size(huri{i}, 2) : -1 : 1 

                    if(size(functii.interpolare(rCurent), 1) ~= size(functii.interpolare(huri{i}{j}), 1))
                        huri{i}{j} = [huri{i}{j}; zeros((size(functii.interpolare(rCurent), 1) - size(functii.interpolare(huri{i}{j}), 1)) / 2, 1)];
                    end

                    r_prev = conv(functii.interpolare(rCurent), h) + conv(functii.interpolare(huri{i}{j}), g);
                    rCurent = r_prev;

                end
                x_intarziat{i} = rCurent;
            end

            x_intarziat = cat(1, x_intarziat{:});
        end

        function [imagine, coef, huri, r, huri_col, r_col] = haar2d(image)
            imagine = imread(image);
            imagine = double(imagine);
            [xdim, ydim, ch] = size(imagine);

            for col = 1 : ydim
                colCurenta = imagine(:, col);
                [coef_col{col}, huri_col{col}, r_col{col}] = functii.proc_haar1d(colCurenta);
            end

            functii.plot_1d_segmente(coef_col, "Haar2D")
            coef_col = cell2mat(coef_col);

            for row = 1 : size(coef_col, 1)
                rowCurent = coef_col(row, :)';
                [coef{row}, huri{row}, r{row}] = functii.proc_haar1d(rowCurent);   
            end
            functii.plot_1d_segmente(coef, "Haar2D")
        end

        function x = inv_haar2d(huri, r, huri_col, r_col)
            h = [1 1] / 2;
            g = [1 -1] / 2;

            L = size(huri_col{1},2);
            
            for i = 1 :size(r_col, 2)
                rCurent = r_col{i};
                size(conv(functii.interpolare(rCurent), h))
                for j = L : -1 : 1 
                    r_prev = conv(functii.interpolare(rCurent), h) + conv(functii.interpolare(huri_col{i}{j}), g);
                    rCurent = r_prev;
                end
                x{i} = rCurent;
            end
            
    
        end 
    end
end