use strict;
use warnings; 
use Path::Tiny;  # to install do cpan -i Path::Tiny
use Env;

=pod

# version_bumper.pl   
# version 0.0002

# Script to help make version changes to pom.xml files in the GSRS project

# Step 1 -- Open terminal 

# Step 2 -- Set environment variables such as:  

export DEFAULT_VERSION=3.1.2-SNAPSHOT

export GSRS_STARTER_VERSION=$DEFAULT_VERSION
export GSRS_SUBSTANCE_VERSION=$DEFAULT_VERSION
export APPLICATIONS_API_VERSION=$DEFAULT_VERSION
export CLINICAL_TRIALS_API_VERSION=$DEFAULT_VERSION
export PRODUCTS_API_VERSION=$DEFAULT_VERSION
export GSRS_CLINICAL_TRIALS_VERSION=$DEFAULT_VERSION

# Step 3 -- cd path/to/microservice/or/module/root/folder 
# Step 4 -- Execute 

> version_bumper.pl <bump_sub_routine> 


# Step 5 - verify 

> grep -rl versionstring  | grep pom.xml | grep -v target  
> git diff 

=cut

my $gsrs_starter_version=              $ENV{GSRS_STARTER_VERSION};
my $gsrs_substance_version=        $ENV{GSRS_SUBSTANCE_VERSION};
my $applications_api_version=       $ENV{APPLICATIONS_API_VERSION};
my $clinical_trials_api_version=     $ENV{CLINICAL_TRIALS_API_VERSION};
my $products_api_version=            $ENV{PRODUCTS_API_VERSION};
my $gsrs_clinical_trials_version=   $ENV{GSRS_CLINICAL_TRIALS_VERSION};


# keep up here to avoid scope issues 
my $path_argument_message='A version_argument is required.';
my $version_argument_message='A version_argument is required.';
my $find_text_argument_message='A find_text_argument is required.';
my $tag_argument_message='A tag_argument is required.';
my $path_not_exists_message='The file path provided does not exist; nothing rewritten.';
my $find_text_regex_not_match_message='The find_text_regex did not match, which may be intentional. No change made to file [%s]';
my $parent_artifact_id_argument_message='A parent_artifact_id (argument) is required.';
my $parent_tag_not_matched_message='No parent tag matched regex; no change made to file [%s]';
my $parent_artifact_id_argument_not_match_message ='Parent artifictId tag [%s] did not match, which may be intentional. No change made to file [%s].' ;


dispatch();

sub dispatch {
  my $bump=$ARGV[0];
  my %bumpers = (
    bump_starter_module  => \&bump_starter_module,
    bump_substances_module  => \&bump_substances_module,
    bump_substances_microservice => \&bump_substances_microservice,
    bump_clinical_trials_module  => \&bump_clinical_trials_module,
    bump_clinical_trials_microservice => \&bump_clinical_trials_microservice,
  );
  if (exists $bumpers{$bump}) {
    $bumpers{$bump}->();
  } else {
    warn "There is no bumper called \"$bump\".\n"
         . join("\n", "Available Bumpers:", keys %bumpers)."\n";
  }
}

sub bump_clinical_trials_module {

  my $gsrs_starter_version_tag='gsrs.version';

  set_property_by_path_and_tag({
          path_argument => './pom.xml',
          version_argument => $gsrs_starter_version,
          tag_argument => $gsrs_starter_version_tag
    }
  );

  set_property_by_path_and_tag({
          path_argument => './pom.xml',
          version_argument => $gsrs_substance_version,
          tag_argument => 'gsrs.substance.version'
    }
  );

  set_property_by_path_and_tag({
          path_argument => './pom.xml',
          version_argument => $gsrs_clinical_trials_version,
          tag_argument => 'gsrs.clinical-trials.version'
    }
  );


  set_main_project_version_by_path_and_regex({
        path_argument => './pom.xml',
        version_argument => $gsrs_clinical_trials_version,
        find_text_argument => '<version>.*</version><!--main_module_version-->'
  });

  find_poms_then_set_parent_versions({ 
    version_argument => $gsrs_clinical_trials_version,
    parent_artifact_id => 'gsrs-module-clinical-trials'
  });

}


sub bump_clinical_trials_microservice {

  my $gsrs_starter_version_tag='gsrs.starter.version';

  set_property_by_path_and_tag({
          path_argument => './pom.xml',
          version_argument => $gsrs_starter_version,
          tag_argument => $gsrs_starter_version_tag
    }
  );

  set_property_by_path_and_tag({
          path_argument => './pom.xml',
          version_argument => $gsrs_substance_version,
          tag_argument => 'gsrs.substance.version'
    }
  );

  set_property_by_path_and_tag({
          path_argument => './pom.xml',
          version_argument => $gsrs_clinical_trials_version,
          tag_argument => 'gsrs.clinical-trials.version'
    }
  );

  set_main_project_version_by_path_and_regex({
        path_argument => './pom.xml',
        version_argument => $gsrs_clinical_trials_version,
        find_text_argument => '<version>.*</version><!--main_microservice_version-->'
  });
}

sub bump_substances_microservice {

  my $gsrs_starter_version_tag='gsrs.starter.version';

  set_property_by_path_and_tag({
          path_argument => './pom.xml',
          version_argument => $gsrs_starter_version,
          tag_argument => $gsrs_starter_version_tag
    }
  );

  set_property_by_path_and_tag({
          path_argument => './pom.xml',
          version_argument => $gsrs_substance_version,
          tag_argument => 'gsrs.substance.version'
    }
  );

  set_main_project_version_by_path_and_regex({
        path_argument => './pom.xml',
        version_argument => $gsrs_substance_version,
        find_text_argument => '<version>.*</version><!--main_microservice_version-->'
  });
}




sub bump_substances_module { 
  my $gsrs_starter_version_tag='gsrs.version';

  set_property_by_path_and_tag({
        path_argument => './pom.xml',
        version_argument => $gsrs_starter_version,
        tag_argument => $gsrs_starter_version_tag
  });

  set_property_by_path_and_tag({
    path_argument => './pom.xml',
    version_argument => $gsrs_substance_version,
    tag_argument => 'gsrs.substance.version'
  });

  set_main_project_version_by_path_and_regex({
    path_argument => './pom.xml',
    version_argument => $gsrs_substance_version,
    find_text_argument => '<version>.*</version><!--main_module_version-->'
  });

  find_poms_then_set_parent_versions({ 
    version_argument => $gsrs_substance_version,
    parent_artifact_id => 'gsrs-module-substances'
  });

  set_version_by_path_and_regex({
  path_argument => './gsrs-fda-substance-extension/pom.xml',
  version_argument => $applications_api_version,
  find_text_argument => '<dependency>\s*
<groupId>gov.nih.ncats</groupId>\s*
<artifactId>applications-api</artifactId>\s*
<version>.*</version>'
  });

  set_version_by_path_and_regex({
    path_argument => './gsrs-fda-substance-extension/pom.xml',
    version_argument => $clinical_trials_api_version,
    find_text_argument => '<dependency>\s*
<groupId>gov.nih.ncats</groupId>\s*
<artifactId>clinical-trials-api</artifactId>\s*
<version>.*</version>'
  });

  set_version_by_path_and_regex({
    path_argument => './gsrs-fda-substance-extension/pom.xml',
    version_argument => $products_api_version,
    find_text_argument => '<dependency>\s*
<groupId>gov.nih.ncats</groupId>\s*
<artifactId>products-api</artifactId>\s*
<version>.*</version>'
  });
 
}

  sub bump_starter_module {

   my $gsrs_starter_version_tag='gsrs.version';

    set_property_by_path_and_tag({
    path_argument => './pom.xml',
    version_argument => $gsrs_starter_version,
    tag_argument => $gsrs_starter_version_tag
  });

  set_main_project_version_by_path_and_regex({
    path_argument => './pom.xml',
    version_argument => $gsrs_starter_version,
    find_text_argument => '<version>.*</version><!--main_module_version-->'
  });

  find_poms_then_set_parent_versions({
    version_argument => $gsrs_starter_version,
    parent_artifact_id => 'gsrs-spring-boot'
  });

  set_version_by_path_and_regex({
    path_argument => './gsrs-discovery/pom.xml',
    version_argument => $gsrs_starter_version,
    find_text_argument => '<groupId>gov.nih.ncats</groupId>\s*
<artifactId>gsrs-discovery</artifactId>\s*
<version>.*</version>\s*
<name>gsrs-discovery</name>'
  });

}

## ===== helper sub routines ===== ##


sub set_parent_version{

  my %args = %{shift()};
  my $path_argument = $args{path_argument};
  my $version_argument = $args{version_argument};
  my $parent_artifact_id = $args{parent_artifact_id};

  # if not here, encountered scope problems when using dispatch subroutine 
 
  if (!defined($path_argument) or !$path_argument) { 
     die ($path_argument_message);
  }
  if (!defined($version_argument) or !$version_argument) { 
     die ($version_argument_message);

  }
  if (!defined($parent_artifact_id) or !$parent_artifact_id) { 
     die ($parent_artifact_id_argument_message);

  }
  my $qr_parent_artifact_id_tag=qr(<artifactId>$parent_artifact_id</artifactId>);

  my $new_version=$version_argument;
  my $file = path($path_argument);

  if (!$file->is_file()) { 
     die ($path_not_exists_message);
  }
  my $full_string = $file->slurp_utf8;
 
  if($full_string =~ /(\s*<parent>.*<\/parent>)/sm) {
    my $parent_string=$1;
    if ($parent_string =~ /$qr_parent_artifact_id_tag/i) {
      my $new_parent_string = $parent_string;
      $new_parent_string =~ s/<version>.*<\/version>/<version>$new_version<\/version>/;
      my $qr_parent_string = qr($parent_string);
      $full_string =~ s/$qr_parent_string/$new_parent_string/;
      $file->spew_utf8($full_string);
    } else { 
       # wierd scope edge case here, see note at variable definition.
       warn sprintf($parent_artifact_id_argument_not_match_message, $parent_artifact_id,  $path_argument);
     }
  } else { 
    warn (sprintf($parent_tag_not_matched_message, $path_argument));
  }
}


sub find_poms_then_set_parent_versions {
  my %args = %{shift()};
  use File::Find;
  my @wanted_files;
  find(
    sub { -f $_ && $_ =~ /pom\.xml/ && push @wanted_files, $File::Find::name }, "."
  );
  foreach(@wanted_files){
    print "$_\n";
    my $file = path($_);
    $args{'path_argument'}=$_;
    set_parent_version(\%args);
  }
}

sub set_main_project_version_by_path_and_regex {
  my $args = shift;
  set_version_by_path_and_regex($args);
}


sub set_version_by_path_and_regex  {  
  my %args = %{shift()};
  my $path_argument = $args{path_argument};
  my $version_argument = $args{version_argument};
  my $find_text_argument = $args{find_text_argument};

  if (!defined($path_argument) or !$path_argument) { 
     die ($path_argument_message);
  }
  if (!defined($version_argument) or !$version_argument) { 
     die ($version_argument_message);
  }
  my $new_version=$version_argument;
  my $file = path($path_argument);
  if (!$file->is_file()) { 
     die ($path_not_exists_message);
  }
  my $re=$find_text_argument;

  $re =~ s/[\r\n]+//g;
  my $qr_re=qr($re);
  # print  "$path_argument\n";
  my $full_string = $file->slurp_utf8;
  if($full_string =~ /($qr_re)/sm) {
    my $sub_string=$1;
    my $new_sub_string=$sub_string;
    $new_sub_string =~ s/<version>.*<\/version>/<version>$new_version<\/version>/;
    my $qr_sub_string = qr($sub_string);
    $full_string =~ s/$qr_sub_string/$new_sub_string/;
    $file->spew_utf8($full_string);
  } else { 
      warn (sprintf("$find_text_regex_not_match_message", $path_argument));
  }
}

sub set_property_by_path_and_tag {  
  my %args = %{shift()};
  my $path_argument = $args{path_argument};
  my $version_argument = $args{version_argument};
  my $tag_argument = $args{tag_argument};

  if (!defined($path_argument) or !$path_argument) { 
     die ($path_argument_message);
  }
  if (!defined($version_argument) or !$version_argument) { 
     die ($version_argument_message);
  }
  if (!defined($tag_argument) or !$tag_argument) { 
     die ($tag_argument_message);
  }
  my $new_version=$version_argument;
  my $file = path($path_argument);
  if (!$file->is_file()) { 
     die ($path_not_exists_message);
  }
  my $full_string = $file->slurp_utf8;
  if($full_string =~ /(<properties>.*<\/properties>)/sm) {
    my $sub_string=$1;
    my $sub_string_re_qr = qr($sub_string);
    my $new_sub_string=$sub_string;
    my $new_sub_string_re ="<$tag_argument>[^<]*</$tag_argument>";
    my $new_sub_string_re_qr = qr($new_sub_string_re);
    my $new_sub_string_replacement = "<$tag_argument>$new_version</$tag_argument>";  
    $new_sub_string =~ s/$new_sub_string_re_qr/$new_sub_string_replacement/sm;
    $full_string =~ s/$sub_string_re_qr/$new_sub_string/sm;
    $file->spew_utf8($full_string);
  } else { 
      warn (sprintf("$find_text_regex_not_match_message", $path_argument));
  }
}


__END__
export gsrs_version="3.1.2-SNAPSHOT"
export gsrs_substance_version="3.1.2-SNAPSHOT"
perl -p -i -e "s/<gsrs.version>.*<\/gsrs.version>/<gsrs.version>"$gsrs_version"<\/gsrs.version>/g" ./pom.xml
perl -p -i -e "s/<gsrs.substance.version>.*<\/gsrs.substance.version>/<gsrs.substance.version>"$gsrs_substance_version"<\/gsrs.substance.version>/g" ./pom.xml
