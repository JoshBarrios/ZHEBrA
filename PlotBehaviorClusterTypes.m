type_traces = [];
traces_all = [];
for k = 1:num_clusters
    for l = 1:size(bhav_data,2)
        if ~isempty(bhav_data(l).bout_data)
            types = bhav_data(l).cluster_ID;
            type_bool = types == k;
            if ~sum(type_bool) == 0
                temp = bhav_data(l).bout_data;
                
                traces = temp(2,type_bool);
                trace_params = temp(1,type_bool);
                % flip tail movements initiated to the left so all tail
                % movement initiations will align
                for m = 1:length(trace_params)
                    c1 = trace_params{1,m}(20);
                    c2 = trace_params{1,m}(34);
                    if ~logical(trace_params{1,m}(17)) && c1 < c2
                        traces{1,m} = -traces{1,m};
                    end
                    %                     if c1 < c2
                    %                         traces{1,m} = -traces{1,m};
                    %                     end
                    
                end
                
                traces_all = cat(2,traces_all,traces);
            end
        end
    end
    type_traces{k} = traces_all;
    traces_all = [];
end
%%
for k = 1:num_clusters
    temp = type_traces{k};
    figure
    for l = 1:size(temp,2)
        this_trace = temp{1,l};
        plot((1:length(this_trace))/500,this_trace,'k')
        hold on
    end
    title(strcat('Cluster Type #',num2str(k)))
    ylabel('Tail Angle (°)')
    xlim([0 0.2])
    ylim([-400 400])
    xlabel('Time (s)')
end