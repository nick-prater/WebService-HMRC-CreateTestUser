package WebService::HMRC::CreateTestUser;

use 5.006;
use Carp;
use Moose;
use namespace::autoclean;

extends 'WebService::HMRC::Request';

=head1 NAME

WebService::HMRC::CreateTestUser - Interact with the UK HMRC CreateTestUser API

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use WebService::HMRC::CreateTestUser;
    my $create = WebService::HMRC::CreateTestUser->new();

    # All methods are 'application-restricted' and require authorisation
    # `server_token` is issued when application is registered with HMRC
    $create->auth->server_token('MY-SERVER-TOKEN');

    # Create 'Individual' user - an imaginary person
    my $person = $create->individual({
        services => ['self-assessment', 'mtd-income-tax']
    });
    print $person->data->{userFullName} if $person->is_success;

    # Create 'Organisation' user - an imaginary company
    my $company = $create->organisation({
        services => ['corporation-tax', 'mtd-vat']
    });
    print $company->data->{userFullName} if $company->is_success;

    # Create 'Agent' user - someone who acts on behalf of another user
    my $agent = $create->agent({
        services => ['agent-services']
    });
    print $agent->data->{userFullName} if $agent->is_success;


=head1 DESCRIPTION

Perl module to interact with the UK's HMRC Making Tax Digital
`CreateTestUser` API, which is used to create imaginary individual,
organisation and agent users for testing with their sandbox endpoints.

For more information, see:
L<https://developer.service.hmrc.gov.uk/api-documentation/docs/api/service/api-platform-test-user/1.0>

=head1 REQUIRES

=over

=item L<WebService::HMRC>

=back

=head1 EXPORTS

Nothing   
   
=head1 PROPERTIES

Inherits from L<WebService::HMRC::Request>.

=head1 METHODS

Inherits from L<WebService::HMRC::Request>.

=head2 individual({ [services => \@service_list] })

Create a test user which is an individual on the HMRC sandbox
environment. Returns a WebService::HMRC::Response object.

=head3 Parameters:

=head4 C<services>

Optionally accepts a list of services for which the new user is enrolled.
Test identifiers and registration numbers are created as needed for these
services. Services may be selected from the following possible values:

=over

=item * C<national-insurance>

Generates a National Insurance number and enrols the user for National
Insurance.

=item * C<self-assessment>

Generates a Self Assessment UTR and enrols the user for Self Assessment.

=item * C<mtd-income-tax>

Generates a National Insurance number and a Making Tax Digital Income Tax ID
and enrols the user for Making Tax Digital Income Tax.

=item * C<customs-services>

Generates an EORI number and enrols the user for Customs Services 

=back

=head3 Response Data:

For full details of the response data, see the HMRC API specification. In
summary, the data is a hashref contains a subset of the following keys,
which vary according to the services specified:

    {
        userId => "945350439195",
        password => "bLohysg8utsa",
        userFullName => "Ida Newton",
        emailAddress => "ida.newton@example.com",
        individualDetails => {
            firstName => "Ida",
            lastName => "Newton",
            dateOfBirth => "1960-06-01",
            address  => {
                line1 => "45 Springfield Rise",
                line2 => "Glasgow",
                postcode => "TS1 1PA"
            },
        },
        saUtr => "1000057161",
        nino => "PE938808A",
        mtdItId => "XJIT00000328268",
        eoriNumber => "GB1234567890",
    }

=cut

sub individual {

    my ($self, $args) = @_;
    my $request_data = {};

    # services is an optional arrayref parameter
    if(defined $args && defined $args->{services}) {
        ref $args->{services} eq 'ARRAY'
            or croak 'services parameter is not an arrayref';

        $request_data->{serviceNames} = $args->{services};
    }

    return $self->post_endpoint_json({
        endpoint => '/create-test-user/individuals',
        data => $request_data,
        auth_type => 'application',
    });
}


=head2 organisation({ [services => \@service_list] })

Create a test company which is an organisation on the HMRC sandbox
environment. Returns a WebService::HMRC::Response object.

=head3 Parameters:

=head4 C<services>

Optionally accepts a list of services for which the new user is enrolled.
Test identifiers and registration numbers are created as needed for these
services. Services may be selected from the following possible values:

=over

=item * C<corporation-tax>

Generates a Corporation Tax UTR and enrols the user for Corporation Tax.

=item * C<paye-for-employers>

Generates an Employer Reference and enrols the user for PAYE for Employers.

=item * C<submit-vat-returns>

Generates a VAT Registration Number and enrols the user for Submit VAT
Returns. Note that this is an older api which is being superceded by the
newer C<mtd-vat> api.

=item * C<national-insurance>
Generates a National Insurance number and enrols the user for National
Insurance.

=item * C<self-assessment>

Generates a Self Assessment UTR and enrols the user for Self Assessment.

=item * C<mtd-income-tax>

Generates a National Insurance number and a Making Tax Digital Income Tax ID
and enrols the user for Making Tax Digital Income Tax.

=item * C<mtd-vat>

Generates a VAT Registration Number and enrols the user for Making Tax
Digital VAT.

=item * C<lisa>

Generates a LISA Manager Reference Number and enrols the user for Lifetime
ISA.

=item * C<secure-electronic-transfer>

Generates a Secure Electronic Transfer Reference Number and enrols the user
for HMRC Secure Electronic Transfer.

=item * C<relief-at-source>

Generates a Pension Scheme Administrator Identifier and enrols the user for
Relief at Source.

=item * C<customs-services>
Generates an EORI number and enrols the user for Customs Services.

=back

=head3 Response Data:

For full details of the response data, see the HMRC API specification. In
summary, the data is a hashref contains a subset of the following keys,
which vary according to the services specified:

    {
        userId => "085603622877",
        password => "nyezgdfrlsmc",
        userFullName => "Ida Newton",
        emailAddress => "ida.newton@example.com",
        organisationDetails => {
            name => "Company ABF123",
            address => {
                line1 => "1 Abbey Road",
                line2 => "Aberdeen",
                postcode => "TS1 1PA"
            },
        },
        saUtr => "8000083480",
        nino => "XM110477D",
        empRef => "538/EMKXYNSVTH",
        ctUtr => "4000082459",
        vrn => "666119668",
        mtdItId => "XJIT00000328268",
        lisaManagerReferenceNumber => "Z123456",
        secureElectronicTransferReferenceNumber => "123456789012",
        pensionSchemeAdministratorIdentifier => "A1234567",
        eoriNumber => "GB1234567890",
    }

=cut

sub organisation {

    my ($self, $args) = @_;
    my $request_data = {};

    # services is an optional arrayref parameter
    if(defined $args && defined $args->{services}) {
        ref $args->{services} eq 'ARRAY'
            or croak 'services parameter is not an arrayref';

        $request_data->{serviceNames} = $args->{services};
    }

    return $self->post_endpoint_json({
        endpoint => '/create-test-user/organisations',
        data => $request_data,
        auth_type => 'application',
    });
}


=head2 agent({ [services => \@service_list] })

Create a test user which is an agent on the HMRC sandbox
environment. Returns a WebService::HMRC::Response object.

=head3 Parameters:

=head4 C<services>

Optionally accepts a list of services for which the new user is enrolled.
Test identifiers and registration numbers are created as needed for these
services. Services may be selected from the following possible values:

=over

=item * C<agent-services>

Generates an Account Number for Agent Services and enrols the user for Agent
Services.

=back

=head3 Response Data:

For full details of the response data, see the HMRC API specification. In
summary, the data is a hashref contains a subset of the following keys,
which vary according to the services specified:

    {
        userId => "945350439195",
        password => "bLohysg8utsa ",
        userFullName => "Ida Newton",
        emailAddress => "ida.newton@example.com",
        agentServicesAccountNumber => "NARN0396245",
    }

=cut

sub agent {

    my ($self, $args) = @_;
    my $request_data = {};

    # services is an optional arrayref parameter
    if(defined $args && defined $args->{services}) {
        ref $args->{services} eq 'ARRAY'
            or croak 'services parameter is not an arrayref';

        $request_data->{serviceNames} = $args->{services};
    }

    return $self->post_endpoint_json({
        endpoint => '/create-test-user/agents',
        data => $request_data,
        auth_type => 'application',
    });
}

=head1 INSTALLATION

To install this module, run the following commands:

    perl Makefile.PL
    make
    make test
    make install

=head1 AUTHORISATION

Except for a small number of open endpoints, access to the HMRC APIs requires
appliction or user credentials. These must be obtained from HMRC. Application
credentials (and documentation) may be obtained from their
L<Developer Hub|https://developer.service.hmrc.gov.uk/api-documentation>

=head1 TESTING

The basic tests are run as part of the installation instructions shown above
use an invalid uri as an endpoint. This tests basic interaction with the
module's method and does not require an internet connection.

Developer pre-release tests may be run with the following command:

    prove -l xt/

With a working internet connection and HMRC application credentials, specified
as environment variables, interaction with the real HMRC api can be tested.
This will result in the creation of test users on the HMRC sandbox platform:

    HMRC_SERVER_TOKEN=[MY-SERVER-TOKEN] make test TEST_VERBOSE=1

=head1 AUTHOR

Nick Prater, <nick@npbroadcast.com>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-webservice-hmrc-createtestuser at rt.cpan.org>, or through
the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WebService-HMRC-CreateTestUser>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT AND DOCUMENTATION

You can find documentation for this module with the perldoc command.

    perldoc WebService::HMRC::CreateTestUser

The C<README.pod> file supplied with this distribution is generated from the
L<WebService::HMRC::CreateTestUser> module's pod by running the following
command from the distribution root:

    perldoc -u lib/WebService/HMRC/CreateTestUser.pm > README.pod

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-HMRC-CreateTestUser>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WebService-HMRC-CreateTestUser>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WebService-HMRC-CreateTestUser>

=item * Search CPAN

L<http://search.cpan.org/dist/WebService-HMRC-CreateTestUser/>

=item * Github

L<https://github.com/nick-prater/WebService-HMRC-CreateTestUser>

=back

=head1 ACKNOWLEDGEMENTS

This module was originally developed for use as part of the
L<LedgerSMB|https://ledgersmb.org/> open source accounting software.

=head1 LICENSE AND COPYRIGHT

Copyright 2018 Nick Prater, NP Broadcast Ltd.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

__PACKAGE__->meta->make_immutable;
1; # End of WebService::HMRC::CreateTestUser
