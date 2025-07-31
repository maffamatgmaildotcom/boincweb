class BoincRpcClient
  require 'socket'
  require 'nokogiri'
  require 'digest'

  attr_reader :host, :port

  # Initialize
  # @param host [String] a hostname or IP
  # @param port [String,Fixnum] a port number
  def initialize(host, port = 31416, password = "deadbeef", trace = false)
    @host = host # "192.168.5.92"
    @port = port
    @password = password
    @trace = trace
  end

  def get_host_info
    request = "get_host_info"
    request_xml = %Q(<boinc_gui_rpc_request><#{request}/></boinc_gui_rpc_request>\003)
    response = do_request(request_xml)
    puts response
    doc = Nokogiri::XML(response)
    host_info = doc.xpath("//host_info")
    timezone = host_info.xpath("timezone").text.to_i
    domain_name = host_info.xpath("domain_name").text
    ip_addr = host_info.xpath("ip_addr").text
    cpid = host_info.xpath("host_cpid").text
    cpu_count = host_info.xpath("p_ncpus").text.to_i
    vendor = host_info.xpath("p_vendor").text
    model = host_info.xpath("p_model").text
    features = host_info.xpath("p_features").text
    fpops = host_info.xpath("p_fpops").text.to_f
    iops = host_info.xpath("p_iops").text.to_f
    membw = host_info.xpath("p_membw").text.to_i
    calculated = host_info.xpath("p_calculated").text.to_i
    vm_extensions_disabled = host_info.xpath("p_vm_extensions_disabled").text.to_i
    nbytes = host_info.xpath("m_nbytes").text.to_i
    cache = host_info.xpath("m_cache").text.to_i
    swap = host_info.xpath("m_swap").text.to_i
    total = host_info.xpath("d_total").text.to_i
    free = host_info.xpath("d_free").text.to_i
    os_name = host_info.xpath("os_name").text
    os_version = host_info.xpath("os_version").text
    product_name = host_info.xpath("product_name").text
    virtualbox_version = host_info.xpath("virtualbox_version").text

    attributes = {
      ip: ip_addr,
      cpid: cpid,
      cpu_count: cpu_count,
      vendor: vendor,
      model: model,
      features: features,
      fpops: fpops,
      iops: iops,
      membw: membw,
      calculated: calculated,
      vm_extensions_disabled: vm_extensions_disabled,
      nbytes: nbytes,
      cache: cache,
      swap: swap,
      total_memory: total,
      free_memory: free,
      os_name: os_name,
      os_version: os_version,
      product_name: product_name,
      virtualbox_version: virtualbox_version,
      domain_name: domain_name,
      timezone: timezone
    }
    # Handle special cases for IP addresses
    if ip_addr == "192.168.5.79" # Mulan 2nd network adapter is not used
      ip_addr = "192.168.5.78" # Mulan 1st network adapter
    end
    attributes[:ip] = ip_addr
    computer = Computer.find_or_initialize_by(ip: ip_addr)
    computer.update(attributes) unless computer.nil?
  end
  
  def get_results(ip)
    request_xml = %Q(<boinc_gui_rpc_request><get_results/><active_only>0</active_only></get_results></boinc_gui_rpc_request>\003)
    begin
      response = do_request(request_xml)
    rescue Errno::ECONNREFUSED => e
      Rails.logger.error "Connection refused for #{ip}: #{e.message}"
      return []
    rescue Errno::ETIMEDOUT => e
      Rails.logger.error "Connection timed out for #{ip}: #{e.message}"
      return []
    rescue StandardError => e
      Rails.logger.error  "An error occurred for #{ip}: #{e.message}"
      return []
    end
    # puts response
    doc = Nokogiri::XML(response)
    results = doc.xpath("//result")
    #puts results
    tasks = []
    results.each do |result|
      task_name = result.xpath("name").text
      wu_name = result.xpath("wu_name").text
      project_url = result.xpath("project_url").text
      final_cpu_time = result.xpath("final_cpu_time").text.to_f
      #final_elapsed_time = result.xpath("final_elapsed_time").text.to_f
      report_deadline = result.xpath("report_deadline").text.to_f
      deadline = Time.at(report_deadline).to_datetime.strftime("%a %b %d, %Y %H:%I:%S")
      remaining = result.xpath("estimated_cpu_time_remaining").text.to_f
      state = result.xpath("state").text.to_i
      fraction_done = result.xpath("active_task/fraction_done")&.text
      #checkpoint_cpu_time = result.xpath("active_task/current_cpu_time")&.text.to_f
      current_cpu_time = result.xpath("active_task/current_cpu_time")&.text.to_f
      elapsed_time = result.xpath("active_task/elapsed_time")&.text.to_f
      percent_done = percent_done_display(state, fraction_done)
      state_string = state_display(state, fraction_done.to_f)

      attributes = {
        computer: BoincRpcClient.hostname(ip),
        name: task_name, 
        application: application_display(wu_name),
        project: project_display(project_url),
        cpu: cpu_display(final_cpu_time, current_cpu_time, elapsed_time),
        progress: percent_done,
        elapsed: elapsed_display(elapsed_time),
        remaining: elapsed_display(remaining),
        deadline: deadline,
        status: state_string,
        result_xml: result.to_xml
      }
      unless task_name.nil? || task_name.empty?
        Task.transaction do
          task = Task.find_or_initialize_by(name: task_name, computer: BoincRpcClient.hostname(ip))
          task.update(attributes)
          task = task.first if task.respond_to?(:first)
          tasks << task 
        end
      end
    end
    tasks
  end

  def self.hostname(ip)
    hosts = { 
      "192.168.5.91" => "olaf",
      "192.168.5.97" => "elsa",
      "192.168.5.81" => "grumpy",
      "192.168.5.94" => "anna",
      "192.168.5.78" => "mulan",
      "192.168.5.79" => "mulan",
      "192.168.5.93" => "sven",
      "192.168.5.75" => "minnie",
      "192.168.5.92" => "kristoff",
    }
    hosts[ip]
  end

  # Values of RESULT::state in client.
  # THESE MUST BE IN NUMERICAL ORDER
  # (because of the > comparison in RESULT::computing_done())
  # see html/inc/common_defs.inc
  # 
  # #define RESULT_NEW                  0 // New result
  # #define RESULT_FILES_DOWNLOADING    1 // Input files for result (WU, app version) are being downloaded
  # #define RESULT_FILES_DOWNLOADED     2 // Files are downloaded, result can be (or is being) computed
  # #define RESULT_COMPUTE_ERROR        3 // computation failed; no file upload
  # #define RESULT_FILES_UPLOADING      4 // Output files for result are being uploaded
  # #define RESULT_FILES_UPLOADED       5 // Files are uploaded, notify scheduling server at some point
  # #define RESULT_ABORTED              6 // result was aborted
  # #define RESULT_UPLOAD_FAILED        7 // some output file permanent failure
  RESULT_STATE = {
    new: 0,
    files_downloading: 1,
    files_downloaded: 2,
    compute_error: 3,
    files_uploading: 4,
    files_uploaded: 5,
    aborted: 6,
    upload_failed: 7
  }
  def result_state_string(value)
    RESULT_STATE.key(value)
  end

  # values of ACTIVE_TASK::task_state
  # 
  # #define PROCESS_UNINITIALIZED   0  // process doesn't exist yet
  # #define PROCESS_EXECUTING       1  // process is running, as far as we know
  # #define PROCESS_SUSPENDED       9  // we've sent it a "suspend" message
  # #define PROCESS_ABORT_PENDING   5  // process exceeded limits; send "abort" message, waiting to exit
  # #define PROCESS_QUIT_PENDING    8  // we've sent it a "quit" message, waiting to exit
  # #define PROCESS_COPY_PENDING    10 // waiting for async file copies to finish
  # states in which the process has exited
  # #define PROCESS_EXITED          2
  # #define PROCESS_WAS_SIGNALED    3
  # #define PROCESS_EXIT_UNKNOWN    4
  # #define PROCESS_ABORTED         6  // aborted process has exited
  # #define PROCESS_COULDNT_START   7
  
  ACTIVE_TASK_STATE = {
    unintialized: 0,
    executing: 1,
    exited: 2,
    was_signaled: 3,
    exit_unknown: 4,
    abort_pending: 5,
    process_aborted: 6,
    process_couldnt_start: 7,
    quit_pending: 8,
    suspended: 9,
    copy_pending: 10
  }
  def active_task_state_string(value)
    ACTIVE_TASK_STATE.key(value)
  end

  private

  def application_display(wu_name)
    app_name = wu_name
    app_name = wu_name.split("_")[0] if wu_name.include?("_")
    app_name = wu_name.split("-")[0] if wu_name.include?("-")
    app_name = wu_name.split(".")[0] if wu_name.include?(".")
    app_name = "Mapping Cancer Markers" if app_name[0..2] == "MCM"
    app_name = "African Rainfall Project" if app_name[0..2] == "ARP"
    app_name
  end

  def cpu_display(final_cpu_time, current_cpu_time, elapsed_time)
    cpu_time_display = final_cpu_time.to_s
    if (final_cpu_time == 0.0) # active task
      if (current_cpu_time == 0.0) || (elapsed_time == 0.0)
        cpu_time_display = "0.0"
      else
        cpu = (current_cpu_time/elapsed_time) * 100.0
        cpu = 100.0 if (cpu > 100.0) 
        cpu_time_display = sprintf("%.2f%%", cpu)
      end
    else
      cpu = (final_cpu_time/elapsed_time) * 100.0
      cpu = 100.0 if (cpu > 100.0) 
      cpu_time_display = sprintf("%.2f%%", cpu) 
    end
    cpu_time_display 
  end

  def elapsed_display(elapsed_seconds)
    days = elapsed_seconds / (60.0 * 60.0 * 24.0)
    full_days = days.to_i
    hours = (days - full_days) * 24.0
    full_hours = hours.to_i
    minutes = (hours - full_hours) * 60.0
    full_minutes = minutes.to_i
    seconds = (minutes - full_minutes) * 60.0
    full_seconds = seconds.to_i
    elapsed = sprintf("%02d:%02d:%02d", full_hours, full_minutes, full_seconds)
    elapsed = sprintf("%02d,%02d:%02d:%02d", full_days, full_hours, full_minutes, full_seconds) if full_days > 0
    elapsed
  end

  def project_display(project_url)
    require 'uri'
    parsed_url = URI.parse(project_url)
    project_name = ""
    project_name = parsed_url.host if parsed_url.host
    parts = project_name.split(".") if project_name.include?(".")
    if parts.length > 2
      project_name = parts[-2]
    elsif parts.length == 2
      project_name = parts[0]
    end
    project_name = "World Community Grid" if project_name == "worldcommunitygrid"
    project_name
  end

  def percent_done_display(state, fraction_done)
    percent_done = "0.0"
    percent_done = sprintf("%.3f%%", fraction_done.to_f * 100.0) unless fraction_done.nil?
    percent_done = "100.0%" if state == 5
    percent_done = "" if percent_done == "0.000%"
    percent_done
  end

  def state_display(state, fraction_done)
    case state
    when 0
      state_string = 'New'
    when 1
      state_string = 'Downloading'
    when 2
      state_string = 'Ready to start'
      state_string = 'Running' if fraction_done > 0.0 && fraction_done < 100.0
    when 3
      state_string = 'Compute error'
    when 4
      state_string = 'Uploading'
    when 5
      state_string = 'Ready to report'
      state_string = 'Completed' if fraction_done == 100.0
    when 6
      state_string = 'Aborted'
    when 7
      state_string = 'Upload failed'
    else
      state_string = 'Unknown'
    end
    state_string
  end

  def do_request(request_xml)
    puts "in do_request..." if @trace
    response = ""
    begin
      socket = TCPSocket.open(@host, @port)
      authenticated = authenticate(socket)
      if authenticated
        puts "in do_request, sending request..." if @trace
        socket.sendmsg(request_xml)
        puts "in do_request, reading response..." if @trace
        response = read_response(socket)
        #puts response unless response.nil?
      else
        puts "unauthorized???"
      end
    ensure
      socket.close if socket 
    end
    response || ""
  end

  def read_response(socket)
    puts "in read_response..." if @trace
    response = ""
    end_marker = "\003"
    msg = ""
    n = nil
    while (true)
      buf = socket.recvmsg(1024)
      if buf.nil?
        puts "Error reading!"
        return nil
      end
      msg = buf[0]
      n = msg.index(end_marker)
      break unless n.nil?
      response += msg
    end
    response += msg[0, n]
    puts "leaving read_response." if @trace
    response
  end

  def authenticate(socket)
    puts "in authenticate..." if @trace
    auth1 = %Q(<boinc_gui_rpc_request><auth1/></boinc_gui_rpc_request>\003)
    socket.sendmsg(auth1)
    response = read_response(socket)
    #debugger
    #puts "response(auth1): #{response}"
    doc = Nokogiri::XML(response)
    nonce_value = doc.xpath("//nonce")[0].content.to_s
    #puts "nonce_value: #{nonce_value}"
    nonce_hash_value = Digest::MD5.hexdigest(nonce_value+@password)
    #puts "nonce_hash_value: #{nonce_hash_value}"
    auth2 = %Q(<boinc_gui_rpc_request><auth2><nonce_hash>#{nonce_hash_value}</nonce_hash></auth2></boinc_gui_rpc_request>\003)
    #puts "auth2: #{auth2}"
    socket.sendmsg(auth2)
    response = read_response(socket)
    #puts "response(auth2): #{response}"
    puts "leaving authenticate." if @trace
    return !response.include?("unauthorized")
  end
end