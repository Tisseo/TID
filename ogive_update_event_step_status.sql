--Rename link_event_step_status TABLE
ALTER TABLE ogive.link_event_step_status
  RENAME TO event_step_status;
--Update CONSTRAINTS
ALTER TABLE ogive.event_step_status
  DROP CONSTRAINT link_event_step_status_pkey;
ALTER TABLE ogive.event_step_status
  ADD CONSTRAINT event_step_status_pkey PRIMARY KEY (id);
--Update FK
ALTER TABLE ogive.event_step_status
  DROP CONSTRAINT link_event_step_status_event_step_id_fk;
ALTER TABLE ogive.event_step_status
  ADD CONSTRAINT event_step_status_event_step_id_fk
FOREIGN KEY (event_step_id) REFERENCES event_step (id);
--Update INDEX
DROP INDEX ogive.link_event_step_status_pkey RESTRICT;
CREATE UNIQUE INDEX event_step_status_pkey
  ON ogive.event_step_status (id);
