{
  simple-timer = interval: description: {
    description = description;
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = interval;
      Persistent = true;
    };
  };
}
