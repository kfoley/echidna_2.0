module EchidnaImport

  class DirNotFound < Exception
  end

  # This 'importer' simply extracts condition names from the
  # experiment directory.
  # To do this, it simply returns all .sig entries in
  # the specified directory. If the directory does not
  # exist, an EchidnaImport::DirNotFound exception is raised

  def conditions(dir)
    if File.directory?(dir)
      result = []
      Dir.new(dir).each {|file|
        if file.start_with?('._')
        else
          result << file if file.end_with?('.sig')
        end
      }
      result
    else
      raise DirNotFound.new
    end
  end

  def conditions_for_tiling(tiling_dir, project_id)
    dir = "#{tiling_dir}/#{project_id}"
    conditions(dir)
  end

  def conditions_for_sbeams(arrays_dir, project_id, timestamp)
    dir = "#{arrays_dir}/Pipeline/output/project_id/#{project_id}/#{timestamp}"
    conditions(dir)
  end
end


