function TransformationGUI
        %Generate random point
        Px = 2*rand(1)-1;
        Py = 2*rand(1)-1;
        point = [Px; Py]; 

        %Create dummy variables and matrix
        tx = 0;
        ty = 0;
        points_initial = zeros(2,18);
        
        %Define colors for initial points
        RGB = {'#00429d', '#2b57a7', '#426cb0','#5681b9', '#6997c2', '#7daeca', '#93c4d2', '#abdad9', '#caefdf', '#ffe2ca', '#ffc4b4', '#ffa59e', '#f98689', '#ed6976', '#dd4c65', '#ca2f55', '#b11346', '#93003a'};
        end_points = [20:20:360]; 
        idx = [1:18]; 
        
        %Create points at 20 degrees distance to form a circle 
        for circle_i = idx
               angle = end_points(circle_i); 
               getRotation(angle)
               points_initial(:,circle_i) = [tx,ty]';
        end
                %Convert degrees to pi measure
                function getRotation(angle)
                        thetaInRadians = angle * (pi/180);

                        cs = cos(thetaInRadians);
                        sn = sin(thetaInRadians);

                        tx = point(1) * cs - point(2) * sn;
                        ty = point(1) * sn + point(2) * cs;
                end
            
        %Generate figure 
        figure; 
        ax1 = axes;
        title(sprintf('Linear Transformations\nReshape Circle')) 
        hold on 
       
        %Plot points
        plot([points_initial(1,:) points_initial(1,1)], [points_initial(2,:) points_initial(2,1)],'k-')
        for circle_i = idx
        
        plot(points_initial(1,circle_i), points_initial(2,circle_i), 'o', 'markerFaceColor', RGB{:,circle_i}, 'markerEdgeColor','k')
        set(ax1,'DataAspectRatio',[1 1 1])
        end
             
        %Make GUI
        figure; 
        enterMatrix = uicontrol('style', 'text', 'string','Enter a Matrix', 'units', 'normalized', 'FontSize', 14, 'position', [0.3 0.75 0.4 0.2]);   
        bracket1 = uicontrol('style', 'text', 'string', '[', 'units', 'normalized', 'FontSize', 55,'position', [0.42 0.69 0.01 0.2]); 
        bracket2 = uicontrol('style', 'text', 'string', ']', 'units', 'normalized', 'FontSize', 55, 'position', [0.57 0.69 0.01 0.2]); 
        m1_field = uicontrol('style','edit','units', 'normalized', 'position', [0.44 0.78 0.05 0.05],'callback', @getM1);
        m2_field = uicontrol('style','edit','units', 'normalized', 'position', [0.51 0.78 0.05 0.05],'callback', @getM2);
        m3_field = uicontrol('style','edit','units', 'normalized', 'position', [0.44 0.7 0.05 0.05],'callback', @getM3);
        m4_field = uicontrol('style','edit','units', 'normalized', 'position', [0.51 0.7 0.05 0.05],'callback', @getM4);
        matrix_multiplication = uicontrol('string', 'Compute','units', 'normalized', 'FontSize', 14,'position', [0.35 0.52 0.3 0.15],'callback', @matrixMultiplication);
        visualizeButton = uicontrol('string','Get Eigenvectors', 'units', 'normalized', 'FontSize', 14, 'position', [0.35 0.2 0.3 0.15], 'callback', @findEig);
        connectButton = uicontrol('string','Show Lines', 'units', 'normalized', 'position', [0.35 0.05 0.145 0.14], 'callback', @showConnection);
        clearButton = uicontrol('string', 'Clear','units','normalized', 'position', [0.51 0.05 0.1425 0.14], 'callback', @clearAxes);
        findEigButton = uicontrol('string', 'Visualize','FontSize',14,'units','normalized', 'position', [0.35 0.36 0.3 0.15], 'callback', @visualizeEllipsis);
        quit_button = uicontrol('string', 'Quit','units','normalized', 'position', [0.8 0.05 0.1 0.05], 'callback', @quitGUI);
        
        %Store user input
        M1 = 0;
        M2 = 0; 
        M3 = 0;    
        M4 = 0;    
        M = zeros(2,2);  
       
        %Store matrix multiplication results
        points_transformed = zeros(2,18);
        
            %Get user matrix input from each edit box
            function getM1(~,~)
              M1 = get(m1_field,'string');  
              M1 = str2double(M1); 
            end

            function getM2(~,~)
                M2 = get(m2_field,'string');
                M2 = str2double(M2); 
            end

            function getM3(~,~)
                 M3 = get(m3_field,'string');   
                 M3 = str2double(M3); 
            end

            function getM4(~,~)
                 M4 = get(m4_field,'string');    
                 M4 = str2double(M4); 
            end
            
            %Multiply each point of the circle with the matrix
            function matrixMultiplication(~,~)
                    M = [M1 M2; M3 M4];
                    points_transformed = M*points_initial;  
                    
                    success_message = figure;
                    success_obj = uicontrol('style','text','string','SUCCESS!', 'FontSize', 24, 'ForegroundColor','g', 'units', 'normalized','position',[0.35 0.4 0.3 0.2]);
                    pause(1)
                    close(success_message)
            end
            
            %Plot transformed points
            function visualizeEllipsis(~,~)
                 plot(ax1,[points_transformed(1,:) points_transformed(1,1)], [points_transformed(2,:) points_transformed(2,1)],'Color',[0.6 0.6 0.6])
                for ellipsis_i = idx
                    plot(ax1,points_transformed(1,ellipsis_i), points_transformed(2,ellipsis_i),'o', 'markerEdgeColor', RGB{1,ellipsis_i}, 'markerFaceColor', RGB{1,ellipsis_i});                                              
                end
                 set(ax1,'DataAspectRatio',[max(points_transformed,[],'all')  max(points_transformed,[],'all') 1])   
            end   
       
            %Show lines between initial and transformed points
            function showConnection(~,~)
               for ellipsis_i = idx
               plot(ax1, [points_initial(1, ellipsis_i) points_transformed(1,ellipsis_i)],[points_initial(2, ellipsis_i) points_transformed(2,ellipsis_i)],'color',RGB{1,ellipsis_i})        
               end
            end
            
            %Clear 
            function clearAxes(~,~)
                     cla(ax1)
                        
                     %re-initialize circle
                     idx = [1:18]; 
                     for circle_i = idx
                             angle = end_points(circle_i); 
                             getRotation(angle)
                             points_initial(:,circle_i) = [tx,ty]';
                             plot(ax1,tx, ty, 'o','markerEdgeColor','k', 'markerFaceColor', RGB{1,circle_i})           
                     end
                     plot(ax1,[points_initial(1,:) points_initial(1,1)], [points_initial(2,:) points_initial(2,1)],'k-')
            end
            
            %quit GUI     
            function quitGUI(~,~)
                    close all 
            end
      
            %Find eigenvalues and eigenvectors
            function findEig(~,~)
                    [v,d] = eig(M); 
                    
                    scale = sqrt(diag(d));

                    v_x1 = v(1,1)*abs(scale(1));
                    v_x2 = v(1,2)*abs(scale(2));
                    v_y1 = v(2,1)*abs(scale(1));
                    v_y2 = v(2,2)*abs(scale(2));

                    % plot eigenvectors           
                    quiver(ax1,0,0,v_x1,v_y1,'k','LineWidth',2);
                    quiver(ax1,0,0,v_x2,v_y2,'r','LineWidth',2);
                    
                    % eigenvector message
                    string_eigval = strcat({'Eigenvalues = '},num2str(round(d(1,1),3)),{', '},num2str(round(d(2,2),3))); 
                    string_eigvec = strcat({'Eigenvectors = ['},num2str(round(v_x1,3)), '/',num2str(round(v_y1,3)),{'], ['},num2str(round(v_x2,3)), '/', num2str(round(v_y2,3)),{']'}); 

                    figure;
                    eigen_val = uicontrol('style','text','string',string_eigval, 'FontSize', 12, 'units', 'normalized','position',[0.24 0.55 0.4 0.05]);
                    eigen_vec = uicontrol('style','text','string',string_eigvec, 'FontSize', 12, 'units', 'normalized','position',[0.24 0.45 0.5 0.1]);
         end
end
