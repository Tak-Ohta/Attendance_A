module ApplicationHelper
  def full_title(page_name = "")
    base_title = "AttendanceApp-A"
    if page_name.empty?
      base_title
    else
      page_name + " | " + base_title
    end
  end
end
