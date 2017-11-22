function display_statistics(name, precision, reinitializations, fps)
    %print statistics to command window
    str = sprintf('Overlap:% 1.3f', precision);

    if ~isnan(reinitializations),
        if reinitializations == round(reinitializations),  %prettier for integer values
            str = [str, sprintf(', reinitializations:% 2i', reinitializations)];
        else
            str = [str, sprintf(', reinitializations:% 1.2f', reinitializations)];
        end
    end

    fprintf('%12s - %s, FPS:% 4.2f\n', name, str, fps)
end
